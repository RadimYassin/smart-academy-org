import sys
import os
import pytest
import unittest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

# Add src to path for direct imports if needed
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../src')))

# Mock Eureka client BEFORE importing main
# This prevents the app from trying to connect to Eureka logic during import/startup
sys.modules['py_eureka_client.eureka_client'] = MagicMock()

from app.main import app
from app.auth.jwt_middleware import get_current_user

@pytest.fixture
def client():
    """
    Test client for the FastAPI application.
    """
    return TestClient(app)

@pytest.fixture
def mock_auth():
    """
    Override the get_current_user dependency.
    """
    def override_get_current_user():
        return {"username": "testuser", "role": "admin"}
    
    app.dependency_overrides[get_current_user] = override_get_current_user
    yield
    app.dependency_overrides = {}

@pytest.fixture
def mock_prepa_data():
    """
    Fixture to mock PrepaData logic.
    """
    with patch('app.routers.prepadata.PrepaData') as mock:
        yield mock

@pytest.fixture
def mock_predictor():
    """
    Fixture to mock PathPredictor logic.
    """
    # We need to patch where it is imported in the router
    with patch('app.routers.predictor.PathPredictor') as mock:
        yield mock
