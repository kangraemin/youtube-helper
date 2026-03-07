"""YouTube Helper 설정 — 환경변수 기반."""

import os

from dotenv import load_dotenv

load_dotenv()

# ── Gemini API ───────────────────────────────────────
GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")

# ── Server ───────────────────────────────────────────
HOST: str = os.getenv("HOST", "0.0.0.0")
PORT: int = int(os.getenv("PORT", "8000"))
