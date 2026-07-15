from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Any
from app.api.dependencies import get_db, get_current_active_admin
from app.repositories.repositories import site_setting as site_setting_repo
from app.schemas.schemas import SiteSetting, SiteSettingBase

router = APIRouter()


@router.get("/", response_model=List[SiteSetting])
def read_settings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return site_setting_repo.get_multi(db, skip=skip, limit=limit)


@router.get("/{key}", response_model=SiteSetting)
def read_setting(key: str, db: Session = Depends(get_db)):
    setting = site_setting_repo.get_by_key(db, key=key)
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    return setting


@router.post("/", response_model=SiteSetting)
def create_setting(
    *,
    db: Session = Depends(get_db),
    setting_in: SiteSettingBase,
    admin: Any = Depends(get_current_active_admin),
):
    return site_setting_repo.create(db, obj_in=setting_in)


@router.put("/{id}", response_model=SiteSetting)
def update_setting(
    *,
    db: Session = Depends(get_db),
    id: int,
    setting_in: SiteSettingBase,
    admin: Any = Depends(get_current_active_admin),
):
    setting = site_setting_repo.get(db, id=id)
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    return site_setting_repo.update(db, db_obj=setting, obj_in=setting_in)


@router.delete("/{id}", response_model=SiteSetting)
def delete_setting(
    *,
    db: Session = Depends(get_db),
    id: int,
    admin: Any = Depends(get_current_active_admin),
):
    setting = site_setting_repo.get(db, id=id)
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    return site_setting_repo.remove(db, id=id)
