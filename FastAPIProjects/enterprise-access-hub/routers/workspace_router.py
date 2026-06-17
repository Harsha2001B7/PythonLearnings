from fastapi import APIRouter
from fastapi import Depends
from auth.dependencies import (
    require_employee,
    require_manager,
    require_admin
)

from schemas.workspace_schema import (
    WorkspaceResponse
)


router = APIRouter(
    prefix="/api/v1/workspaces",
    tags=["Workspaces"]
)


@router.get(
    "/personal",
    response_model=WorkspaceResponse
)
def personal_workspace(
    current_user=Depends(
        require_employee
    )
):
    return {
        "message":
        f"Welcome {current_user.Username} to Personal Workspace"
    }


@router.get(
    "/team",
    response_model=WorkspaceResponse
)
def team_workspace(
    current_user=Depends(
        require_manager
    )
):
    return {
        "message":
        f"Welcome {current_user.Username} to Team Workspace"
    }


@router.get(
    "/company",
    response_model=WorkspaceResponse
)
def company_workspace(
    current_user=Depends(
        require_admin
    )
):
    return {
        "message":
        f"Welcome {current_user.Username} to Company Workspace"
    }