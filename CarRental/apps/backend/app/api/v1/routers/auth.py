from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import secrets

from app.db.session import get_db
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    verify_token
)
from app.models.models import User, Role, RefreshToken, PasswordResetToken, UserSession
from app.schemas.schemas import (
    UserCreate,
    UserResponse,
    Token,
    RefreshTokenRequest,
    PasswordResetRequest,
    PasswordResetConfirm
)

router = APIRouter()

@router.post("/register", response_model=UserResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    # Check if email exists
    user = db.query(User).filter(User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="A user with this email already exists."
        )
    
    # Get user role
    user_role = db.query(Role).filter(Role.name == "User").first()
    role_id = user_role.id if user_role else 2 # default to 2
    
    # Create user
    new_user = User(
        email=user_in.email,
        first_name=user_in.first_name,
        last_name=user_in.last_name,
        phone=user_in.phone,
        country=user_in.country,
        password_hash=get_password_hash(user_in.password),
        role_id=role_id,
        status="active",
        is_verified=False
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
def login(request: Request, user_in: UserCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_in.email).first()
    if not user or not verify_password(user_in.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email or password"
        )
    
    if user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User account is disabled"
        )
    
    # Generate tokens
    role_name = user.role_rel.name if user.role_rel else "User"
    access_token = create_access_token(user.id, role=role_name)
    refresh_token_str = create_refresh_token(user.id, role=role_name)
    
    # Save refresh token in DB
    db_refresh = RefreshToken(
        token=refresh_token_str,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=7)
    )
    db.add(db_refresh)
    
    # Log session
    user_agent = request.headers.get("user-agent")
    ip_address = request.client.host if request.client else None
    session = UserSession(
        user_id=user.id,
        ip_address=ip_address,
        user_agent=user_agent
    )
    db.add(session)
    
    # Update last login
    user.last_login = datetime.utcnow()
    db.commit()
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token_str,
        "token_type": "bearer"
    }

@router.post("/refresh", response_model=Token)
def refresh(refresh_req: RefreshTokenRequest, db: Session = Depends(get_db)):
    # Validate in database
    db_token = db.query(RefreshToken).filter(
        RefreshToken.token == refresh_req.refresh_token,
        RefreshToken.revoked_at == None
    ).first()
    
    if not db_token or db_token.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )
    
    payload = verify_token(refresh_req.refresh_token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token signature"
        )
    
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user or user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or disabled"
        )
    
    # Revoke current refresh token (rotation)
    db_token.revoked_at = datetime.utcnow()
    
    # Issue new ones
    role_name = user.role_rel.name if user.role_rel else "User"
    new_access = create_access_token(user.id, role=role_name)
    new_refresh = create_refresh_token(user.id, role=role_name)
    
    # Save new refresh token
    new_db_refresh = RefreshToken(
        token=new_refresh,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=7)
    )
    db.add(new_db_refresh)
    db.commit()
    
    return {
        "access_token": new_access,
        "refresh_token": new_refresh,
        "token_type": "bearer"
    }

@router.post("/logout")
def logout(refresh_req: RefreshTokenRequest, db: Session = Depends(get_db)):
    db_token = db.query(RefreshToken).filter(RefreshToken.token == refresh_req.refresh_token).first()
    if db_token:
        db_token.revoked_at = datetime.utcnow()
        db.commit()
    return {"message": "Successfully logged out"}

@router.post("/forgot-password")
def forgot_password(req: PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        # Avoid user enumeration, return success anyway
        return {"message": "If the email exists, a reset link has been sent."}
    
    # Generate token
    token = secrets.token_urlsafe(32)
    reset_token = PasswordResetToken(
        token=token,
        email=req.email,
        expires_at=datetime.utcnow() + timedelta(hours=1)
    )
    db.add(reset_token)
    db.commit()
    
    # In production, send email. For local, we print/return it for testing.
    print(f"PASSWORD RESET LINK: http://localhost:5173/reset-password?token={token}")
    return {"message": "Password reset link generated.", "token": token} # Return token for easy testing/auto-filling

@router.post("/reset-password")
def reset_password(req: PasswordResetConfirm, db: Session = Depends(get_db)):
    reset_token = db.query(PasswordResetToken).filter(
        PasswordResetToken.token == req.token,
        PasswordResetToken.used_at == None
    ).first()
    
    if not reset_token or reset_token.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=400,
            detail="Invalid or expired reset token"
        )
    
    user = db.query(User).filter(User.email == reset_token.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.password_hash = get_password_hash(req.new_password)
    reset_token.used_at = datetime.utcnow()
    db.commit()
    return {"message": "Password has been reset successfully."}
