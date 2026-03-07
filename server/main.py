from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import HOST, PORT
from routers.api_v1 import router as api_v1_router

app = FastAPI(title="YouTube Helper API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_v1_router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
