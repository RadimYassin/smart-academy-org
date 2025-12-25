import pytest
from fastapi.testclient import TestClient
from unittest.mock import MagicMock
import sys
import os

# Ensure the project root is in the python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app
from core.config import settings

@pytest.fixture
def client():
    """
    Fixture for FastAPI TestClient
    """
    return TestClient(app)

@pytest.fixture
def mock_rag_service(mocker):
    """
    Mock the RAG service to avoid loading FAISS or calling LLMs during route tests.
    """
    # Mock 'services.rag.ask_question' as it is imported in routers/chat.py
    return mocker.patch("routers.chat.ask_question")

@pytest.fixture
def mock_settings(mocker):
    """
    Mock settings if needed
    """
    mocker.patch.object(settings, "llm_provider", "openai")
    return settings
