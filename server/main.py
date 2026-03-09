from fastapi import FastAPI
from server.routers import transcript, summarize, chat

app = FastAPI(title="YouTube Helper API", version="1.0.0")

app.include_router(transcript.router, prefix="/api/v1", tags=["transcript"])
app.include_router(summarize.router, prefix="/api/v1", tags=["summarize"])
app.include_router(chat.router, prefix="/api/v1", tags=["chat"])


@app.get("/health")
async def health():
    return {"status": "ok"}
