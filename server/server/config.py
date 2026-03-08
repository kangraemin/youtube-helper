import os


class Settings:
    GEMINI_API_KEY: str = os.environ.get("GEMINI_API_KEY", "")
    CORS_ORIGINS: list[str] = ["*"]
    API_V1_PREFIX: str = "/api/v1"


settings = Settings()
