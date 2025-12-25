import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from fastapi import status

def test_ingest_documents_success(client, mock_settings):
    """Test successful document ingestion"""
    with patch("routers.admin.ingest_documents") as mock_ingest:
        mock_ingest.return_value = {
            "status": "success",
            "files_processed": 5,
            "total_pages": 50,
            "total_chunks": 100,
            "message": "Ingestion réussie",
            "index_path": "./mock_index"
        }
        
        response = client.post("/admin/ingest", json={"use_local_pdfs": True})
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "success"
        assert data["files_processed"] == 5
        mock_ingest.assert_called_once()

def test_ingest_documents_error(client, mock_settings):
    """Test ingestion error handling"""
    with patch("routers.admin.ingest_documents") as mock_ingest:
        mock_ingest.side_effect = Exception("Ingestion failed")
        
        response = client.post("/admin/ingest", json={"use_local_pdfs": True})
        
        assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert "Ingestion failed" in response.json()["detail"]

def test_health_check_success(client, mock_settings):
    """Test health check endpoint"""
    with patch("os.path.exists") as mock_exists:
        mock_exists.return_value = True
        
        response = client.get("/health")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "healthy"
        assert data["faiss_index_exists"] is True

def test_health_check_no_index(client, mock_settings):
    """Test health check when index is missing"""
    with patch("os.path.exists") as mock_exists:
        mock_exists.return_value = False
        
        response = client.get("/health")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["faiss_index_exists"] is False
