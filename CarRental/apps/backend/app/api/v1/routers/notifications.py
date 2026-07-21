from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.db.session import get_db
from app.models.models import User, NotificationHistory, UserDevice
from app.schemas.schemas import (
    DeviceRegisterRequest,
    DeviceResponse,
    NotificationResponse,
    UnreadCountResponse,
    TestNotificationRequest,
)
from app.api.dependencies import get_current_user, get_current_active_admin
from app.services.notification_service import NotificationService

router = APIRouter()


@router.post("/devices", response_model=DeviceResponse)
def register_device(
    device_in: DeviceRegisterRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Register or update an FCM token for the logged-in user."""
    return NotificationService.register_device(
        db=db,
        user_id=current_user.id,
        fcm_token=device_in.fcm_token,
        platform=device_in.platform or "android",
        device_name=device_in.device_name,
        app_version=device_in.app_version,
    )


@router.delete("/devices/{fcm_token}")
def unregister_device(
    fcm_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Unregister an FCM token when user logs out."""
    success = NotificationService.unregister_device(
        db=db,
        user_id=current_user.id,
        fcm_token=fcm_token,
    )
    return {"success": success, "message": "Device token removed"}


@router.get("/", response_model=List[NotificationResponse])
def get_user_notifications(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Fetch all notification history for current user ordered by latest first."""
    return (
        db.query(NotificationHistory)
        .filter(NotificationHistory.user_id == current_user.id)
        .order_by(NotificationHistory.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.get("/unread-count", response_model=UnreadCountResponse)
def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get total unread notification count for bell icon badge."""
    count = (
        db.query(NotificationHistory)
        .filter(
            NotificationHistory.user_id == current_user.id,
            NotificationHistory.is_read == False,
        )
        .count()
    )
    return {"unread_count": count}


@router.patch("/{notification_id}/read", response_model=NotificationResponse)
def mark_notification_as_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Mark a specific notification as read."""
    notification = (
        db.query(NotificationHistory)
        .filter(
            NotificationHistory.id == notification_id,
            NotificationHistory.user_id == current_user.id,
        )
        .first()
    )
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification


@router.patch("/read-all")
def mark_all_as_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Mark all notifications as read for current user."""
    db.query(NotificationHistory).filter(
        NotificationHistory.user_id == current_user.id,
        NotificationHistory.is_read == False,
    ).update({"is_read": True})
    db.commit()
    return {"success": True, "message": "All notifications marked as read"}


@router.post("/admin/test-send", response_model=NotificationResponse)
def admin_test_send_notification(
    test_in: TestNotificationRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin),
):
    """Admin test endpoint to send a push notification to any user ID."""
    user = db.query(User).filter(User.id == test_in.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Target user not found")

    return NotificationService.send_to_user(
        db=db,
        user_id=test_in.user_id,
        title=test_in.title,
        message=test_in.message,
        notification_type=test_in.notification_type or "admin_test",
        sender_type="admin",
        image_url=test_in.image_url,
        action_route=test_in.action_route,
    )
