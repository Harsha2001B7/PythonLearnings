import os
import json
import logging
from datetime import datetime
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session

import firebase_admin
from firebase_admin import credentials, messaging

from app.models.models import UserDevice, NotificationHistory, User, Role

logger = logging.getLogger(__name__)

# Initialize Firebase Admin SDK using secrets/firebase-service-account.json
_firebase_initialized = False

def initialize_firebase():
    global _firebase_initialized
    if _firebase_initialized:
        return True

    # Build absolute path to secrets/firebase-service-account.json
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    cred_path = os.path.join(base_dir, "secrets", "firebase-service-account.json")

    if not os.path.exists(cred_path):
        logger.warning(f"Firebase credentials file not found at {cred_path}. Push notifications will run in mock mode.")
        return False

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        _firebase_initialized = True
        logger.info("Firebase Admin SDK successfully initialized.")
        return True
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
        return False


def _format_image_url(url: Optional[str]) -> Optional[str]:
    if not url:
        return None
    if url.startswith("http://") or url.startswith("https://"):
        return url
    if url.startswith("/"):
        return f"http://127.0.0.1:8000{url}"
    return f"http://127.0.0.1:8000/{url}"


class NotificationService:
    @staticmethod
    def register_device(
        db: Session,
        user_id: int,
        fcm_token: str,
        platform: str = "android",
        device_name: Optional[str] = None,
        app_version: Optional[str] = None,
    ) -> UserDevice:
        """Register or update an FCM token for a user."""
        existing = db.query(UserDevice).filter(UserDevice.fcm_token == fcm_token).first()
        now = datetime.utcnow()
        if existing:
            existing.user_id = user_id
            existing.platform = platform
            if device_name:
                existing.device_name = device_name
            if app_version:
                existing.app_version = app_version
            existing.updated_at = now
            existing.last_seen = now
            db.commit()
            db.refresh(existing)
            return existing
        else:
            device = UserDevice(
                user_id=user_id,
                fcm_token=fcm_token,
                platform=platform,
                device_name=device_name,
                app_version=app_version,
                created_at=now,
                updated_at=now,
                last_seen=now,
            )
            db.add(device)
            db.commit()
            db.refresh(device)
            return device

    @staticmethod
    def unregister_device(db: Session, user_id: int, fcm_token: str) -> bool:
        """Unregister an FCM token upon user logout."""
        deleted = db.query(UserDevice).filter(
            UserDevice.user_id == user_id,
            UserDevice.fcm_token == fcm_token
        ).delete()
        db.commit()
        return deleted > 0

    @staticmethod
    def send_to_user(
        db: Session,
        user_id: int,
        title: str,
        message: str,
        notification_type: str = "general",
        sender_type: str = "system",
        image_url: Optional[str] = None,
        booking_id: Optional[int] = None,
        vehicle_id: Optional[int] = None,
        vehicle_name: Optional[str] = None,
        vehicle_image: Optional[str] = None,
        booking_reference: Optional[str] = None,
        priority: str = "high",
        action_route: Optional[str] = None,
        action_payload: Optional[Dict[str, Any]] = None,
    ) -> NotificationHistory:
        """Send a push notification to a user's registered devices and record notification history."""
        # 1. Format full absolute HTTP image URL for FCM push banners
        formatted_vehicle_img = _format_image_url(vehicle_image)
        formatted_img_url = _format_image_url(image_url) or formatted_vehicle_img

        payload_str = json.dumps(action_payload) if action_payload else None
        record = NotificationHistory(
            user_id=user_id,
            sender_type=sender_type,
            title=title,
            message=message,
            notification_type=notification_type,
            image_url=formatted_img_url,
            booking_id=booking_id,
            vehicle_id=vehicle_id,
            vehicle_name=vehicle_name,
            vehicle_image=formatted_vehicle_img,
            booking_reference=booking_reference,
            status="sent",
            priority=priority,
            is_read=False,
            action_route=action_route,
            action_payload=payload_str,
            created_at=datetime.utcnow(),
        )
        db.add(record)
        db.commit()
        db.refresh(record)

        # 2. Attempt FCM push send if Firebase initialized
        fb_active = initialize_firebase()
        if fb_active:
            devices = db.query(UserDevice).filter(UserDevice.user_id == user_id).all()
            for dev in devices:
                try:
                    data_dict = {
                        "notification_id": str(record.id),
                        "notification_type": notification_type,
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    }
                    if action_route:
                        data_dict["action_route"] = action_route
                    if booking_id:
                        data_dict["booking_id"] = str(booking_id)
                    if vehicle_id:
                        data_dict["vehicle_id"] = str(vehicle_id)
                    if vehicle_name:
                        data_dict["vehicle_name"] = vehicle_name
                    if formatted_vehicle_img:
                        data_dict["vehicle_image"] = formatted_vehicle_img
                    if booking_reference:
                        data_dict["booking_reference"] = booking_reference
                    if formatted_img_url:
                        data_dict["image_url"] = formatted_img_url

                    fcm_msg = messaging.Message(
                        notification=messaging.Notification(
                            title=title,
                            body=message,
                            image=formatted_img_url,
                        ),
                        data=data_dict,
                        token=dev.fcm_token,
                        android=messaging.AndroidConfig(
                            priority="high" if priority == "high" else "normal",
                            notification=messaging.AndroidNotification(
                                title=title,
                                body=message,
                                image=formatted_img_url,
                                channel_id="falconview_notifications",
                                sound="default",
                                icon="launcher_icon",
                            ),
                        ),
                    )
                    messaging.send(fcm_msg)
                    logger.info(f"FCM push notification sent successfully to user {user_id} on token {dev.fcm_token[:15]}...")
                except messaging.UnregisteredError:
                    logger.warning(f"Removing invalid FCM token {dev.fcm_token[:15]} for user {user_id}")
                    db.delete(dev)
                    db.commit()
                except Exception as e:
                    logger.error(f"FCM push send error for token {dev.fcm_token[:15]}: {e}")

        return record

    @staticmethod
    def send_to_admins(
        db: Session,
        title: str,
        message: str,
        notification_type: str = "admin_alert",
        image_url: Optional[str] = None,
        booking_id: Optional[int] = None,
        vehicle_id: Optional[int] = None,
        vehicle_name: Optional[str] = None,
        vehicle_image: Optional[str] = None,
        booking_reference: Optional[str] = None,
        action_route: Optional[str] = "/admin",
        action_payload: Optional[Dict[str, Any]] = None,
    ) -> List[NotificationHistory]:
        """Send notification to all active admin users in the system."""
        admins = (
            db.query(User)
            .outerjoin(Role, User.role_id == Role.id)
            .filter((User.role_id == 1) | (Role.name.ilike("%admin%")))
            .all()
        )
        if not admins:
            admins = db.query(User).filter((User.role_id == 1) | (User.email.ilike("%admin%"))).all()

        sent_records = []
        for admin in admins:
            rec = NotificationService.send_to_user(
                db=db,
                user_id=admin.id,
                title=title,
                message=message,
                notification_type=notification_type,
                sender_type="system",
                image_url=image_url,
                booking_id=booking_id,
                vehicle_id=vehicle_id,
                vehicle_name=vehicle_name,
                vehicle_image=vehicle_image,
                booking_reference=booking_reference,
                action_route=action_route,
                action_payload=action_payload,
            )
            sent_records.append(rec)

        return sent_records
