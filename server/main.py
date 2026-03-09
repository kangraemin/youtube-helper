from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import transcript, summarize, chat

app = FastAPI(title="YouTube Helper API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(transcript.router)
app.include_router(summarize.router)
app.include_router(chat.router)
