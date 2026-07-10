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
    UserMeResponse,
    Token,
    RefreshTokenRequest,
    PasswordResetRequest,
    PasswordResetConfirm,
    GoogleLoginRequest
)
from app.api.dependencies import get_current_user
from app.core.config import settings
import httpx

router = APIRouter()

@router.get("/me", response_model=UserMeResponse)
def get_me(current_user: User = Depends(get_current_user)):
    role_name = current_user.role_rel.name if current_user.role_rel else "User"
    permissions = ["admin"] if role_name == "Admin" else ["customer"]
    first_name = current_user.first_name or ""
    last_name = current_user.last_name or ""
    full_name = f"{first_name} {last_name}".strip() or current_user.email
    return {
        "id": current_user.id,
        "name": full_name,
        "email": current_user.email,
        "role": role_name,
        "permissions": permissions,
        "avatar": current_user.avatar_url or current_user.profile_image,
        "created_at": current_user.created_at,
        "first_name": current_user.first_name,
        "last_name": current_user.last_name,
        "phone": current_user.phone,
        "country": current_user.country,
        "status": current_user.status,
        "is_verified": current_user.is_verified,
        "role_id": current_user.role_id
    }

@router.post("/google", response_model=Token)
async def google_login(request: Request, body: GoogleLoginRequest, db: Session = Depends(get_db)):
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"https://oauth2.googleapis.com/tokeninfo?id_token={body.id_token}")
        if resp.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid Google ID token"
            )
        id_info = resp.json()
        
    if id_info.get("iss") not in ["accounts.google.com", "https://accounts.google.com"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token issuer"
        )
        
    if id_info.get("aud") != settings.GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Audience mismatch"
        )
        
    email = id_info.get("email")
    google_sub = id_info.get("sub")
    first_name = id_info.get("given_name", "")
    last_name = id_info.get("family_name", "")
    avatar = id_info.get("picture", "")
    
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Google account does not provide email access"
        )
        
    user = db.query(User).filter(User.email == email).first()
    
    if user:
        if not user.google_sub:
            user.google_sub = google_sub
        if user.auth_provider == "LOCAL" or not user.auth_provider:
            user.auth_provider = "GOOGLE"
        if avatar and user.avatar_url != avatar:
            user.avatar_url = avatar
        if first_name and user.first_name != first_name:
            user.first_name = first_name
        if last_name and user.last_name != last_name:
            user.last_name = last_name
    else:
        user_role = db.query(Role).filter(Role.name == "User").first()
        role_id = user_role.id if user_role else 2
        
        import secrets
        placeholder_pw = secrets.token_urlsafe(32)
        from app.core.security import get_password_hash
        password_hash = get_password_hash(placeholder_pw)
        
        user = User(
            email=email,
            first_name=first_name,
            last_name=last_name,
            google_sub=google_sub,
            auth_provider="GOOGLE",
            avatar_url=avatar,
            password_hash=password_hash,
            role_id=role_id,
            status="active",
            is_verified=True
        )
        db.add(user)
        
    db.commit()
    db.refresh(user)

    role_name = user.role_rel.name if user.role_rel else "User"
    access_token = create_access_token(user.id, role=role_name)
    refresh_token_str = create_refresh_token(user.id, role=role_name)
    
    db_refresh = RefreshToken(
        token=refresh_token_str,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=7)
    )
    db.add(db_refresh)
    
    user_agent = request.headers.get("user-agent")
    ip_address = request.client.host if request.client else None
    session = UserSession(
        user_id=user.id,
        ip_address=ip_address,
        user_agent=user_agent
    )
    db.add(session)
    
    user.last_login = datetime.utcnow()
    db.commit()
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token_str,
        "token_type": "bearer"
    }

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
    db_token = db.query(RefreshToken).filter(
        RefreshToken.token == refresh_req.refresh_token
    ).first()
    
    if not db_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
        
    now = datetime.utcnow()
    is_expired = db_token.expires_at < now
    is_revoked_past_grace = (
        db_token.revoked_at is not None 
        and db_token.revoked_at < now - timedelta(seconds=10)
    )
    
    if is_expired or is_revoked_past_grace:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Expired or revoked refresh token"
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
    
    if db_token.revoked_at is None:
        db_token.revoked_at = now
    
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
