import time

async def request_timer(
        request,
        call_next
):
    start = time.time()

    response = await call_next(
        request
    )

    end = time.time()

    response.headers["X-Process-Time"] = str(round(end - start,4))

    return response