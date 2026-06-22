from pydantic import BaseModel


class DashboardResponse(BaseModel):

    total_tasks: int

    pending_tasks: int

    completed_tasks: int
