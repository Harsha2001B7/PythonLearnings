from pydantic import BaseModel

class WorkspaceResponse(
    BaseModel
):
    message: str