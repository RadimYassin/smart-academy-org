import pytest
from unittest.mock import MagicMock, patch
import pandas as pd

def test_get_profiler_status(client):
    """
    Test GET /api/profiler/status
    """
    response = client.get("/api/profiler/status")
    assert response.status_code == 200
    assert response.json()["status"] == "UP"
    assert "K-Means" in response.json()["algorithm"]

def test_profile_students_success(client, mock_auth):
    """
    Test POST /api/profiler/profile
    """
    with patch('app.routers.profiler.StudentProfiler') as mock_profiler_cls, \
         patch('pandas.read_csv') as mock_read_csv, \
         patch('os.path.exists', return_value=True), \
         patch('os.makedirs'):
         
        mock_read_csv.return_value = pd.DataFrame({'ID': [1, 2], 'Total': [10, 20]})
        mock_instance = mock_profiler_cls.return_value
        mock_instance.run_all.return_value = pd.DataFrame({'ID': [1, 2], 'Cluster': [0, 1]})
        
        response = client.post("/api/profiler/profile", json={"n_clusters": 2})
        
        assert response.status_code == 200
        assert response.json()["status"] == "success"
        assert response.json()["total_students"] == 2


def test_profile_data_not_found(client, mock_auth):
    """
    Test POST /api/profiler/profile when file missing
    """
    with patch('os.path.exists', return_value=False):
        response = client.post("/api/profiler/profile", json={})
        assert response.status_code == 404
        assert "Not Found" in response.json()["detail"] or "not found" in response.json()["detail"].lower()

