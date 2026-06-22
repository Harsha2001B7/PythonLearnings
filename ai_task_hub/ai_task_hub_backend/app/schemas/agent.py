from pydantic import BaseModel


class AgentSummaryRequest(BaseModel):

    question: str


class AgentSummaryResponse(BaseModel):

    question: str

    summary: str
