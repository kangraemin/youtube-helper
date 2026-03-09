import pytest
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.fixture
def client():
    import httpx
    transport = ASGITransport(app=app)
    return httpx.AsyncClient(transport=transport, base_url="http://test")


@pytest.fixture
def anyio_backend():
    return "asyncio"
