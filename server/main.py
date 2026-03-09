import uvicorn
from fastapi import FastAPI
from app.api.v1.router import router as v1_router

app = FastAPI(title="YouTube Helper API", version="0.1.0")
app.include_router(v1_router, prefix="/api/v1")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
