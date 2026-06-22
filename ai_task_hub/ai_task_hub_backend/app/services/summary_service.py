from app.models.task import Task


def build_task_summary(tasks: list[Task]) -> str:

    if not tasks:
        return "You have no tasks."

    pending = [task for task in tasks if task.status == "pending"]
    completed = [task for task in tasks if task.status == "completed"]
    other = [
        task
        for task in tasks
        if task.status not in ("pending", "completed")
    ]

    parts = [
        f"You have {len(tasks)} task(s): "
        f"{len(pending)} pending, {len(completed)} completed."
    ]

    if pending:
        pending_details = ", ".join(
            f"{task.title} ({task.priority})" for task in pending
        )
        parts.append(f"Pending: {pending_details}.")

    if completed:
        completed_details = ", ".join(
            f"{task.title} ({task.priority})" for task in completed
        )
        parts.append(f"Completed: {completed_details}.")

    if other:
        other_details = ", ".join(
            f"{task.title} ({task.status}, {task.priority})" for task in other
        )
        parts.append(f"Other: {other_details}.")

    return " ".join(parts)
