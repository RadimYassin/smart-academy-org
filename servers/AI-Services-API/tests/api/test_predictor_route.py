import pytest
import os
from unittest.mock import MagicMock, mock_open, patch

def test_train_endpoint(client, mock_auth, mock_predictor):
    """
    Test POST /api/predictor/train
    """
    # Mock file existence check
    with patch('os.path.exists', return_value=True):
        # Mock internal operations
        mock_instance = mock_predictor.return_value
        mock_instance.model = MagicMock()
        mock_instance.X_test = [[1, 2]]
        mock_instance.y_test = [1]
        
        # Mock sklearn accuracy_score because it's imported inside the route
        with patch('sklearn.metrics.accuracy_score', return_value=0.95):
            mock_instance.model.predict.return_value = [1]
            
            response = client.post("/api/predictor/train", json={"use_grid_search": False})
            
            assert response.status_code == 200
            assert response.json()["status"] == "success"
            assert response.json()["accuracy"] == 0.95

def test_predict_endpoint_success(client, mock_auth):
    """
    Test POST /api/predictor/predict
    """
    # Mock loading pickle model
    mock_model = MagicMock()
    mock_model.predict.return_value = [1] # Fail
    mock_model.predict_proba.return_value = [[0.1, 0.9]] # High Fail prob
    
    with patch('os.path.exists', return_value=True), \
         patch('builtins.open', mock_open(read_data=b"data")), \
         patch('pickle.load', return_value=mock_model):
        
        payload = {
            "student_data": {
                "ID": 123,
                "Gender": "M",
                "Total": 5.0
            }
        }
        
        response = client.post("/api/predictor/predict", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data["prediction"] == "Fail"
        assert data["risk_level"] == "High"

def test_predict_model_not_found(client, mock_auth):
    """
    Test POST /api/predictor/predict when model is missing
    """
    with patch('os.path.exists', return_value=False):
        response = client.post("/api/predictor/predict", json={"student_data": {}})
        assert response.status_code == 404
        assert "not found" in response.json()["detail"]

def test_get_predictor_status(client):
    """
    Test GET /api/predictor/status
    """
    with patch('os.path.exists', return_value=True):
        response = client.get("/api/predictor/status")
        assert response.status_code == 200
        assert response.json()["status"] == "UP"
        assert response.json()["model_trained"] == True

def test_predict_batch_from_lms_success(client, mock_auth):
    """
    Test POST /api/predictor/predict-batch-from-lms
    """
    # Mock model
    mock_model = MagicMock()
    mock_model.predict.return_value = [0, 1]
    mock_model.predict_proba.return_value = [[0.9, 0.1], [0.2, 0.8]]
    
    # Mock LMS Response
    lms_data = [
        {'studentId': 1, 'studentName': 'Alice', 'subject': 'Math', 'practical': 15, 'theoretical': 15, 'total': 30},
        {'studentId': 2, 'studentName': 'Bob', 'subject': 'Math', 'practical': 5, 'theoretical': 5, 'total': 10}
    ]
    
    with patch('os.path.exists', return_value=True), \
         patch('builtins.open', mock_open(read_data=b"data")), \
         patch('pickle.load', return_value=mock_model), \
         patch('httpx.AsyncClient.get') as mock_get:
         
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = lms_data
        mock_get.return_value = mock_resp
        
        response = client.post("/api/predictor/predict-batch-from-lms", headers={"Authorization": "Bearer test"})
        
        assert response.status_code == 200
        data = response.json()
        assert data["total_students"] == 2
        assert data["high_risk_count"] == 1
        assert len(data["predictions"]) == 2

def test_debug_lms_data(client, mock_auth):
    """
    Test GET /api/predictor/debug-lms-data
    """
    with patch('httpx.AsyncClient.get') as mock_get:
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [{"id": 1}]
        mock_get.return_value = mock_resp
        
        response = client.get("/api/predictor/debug-lms-data")
        assert response.status_code == 200
        assert response.json()["status_code"] == 200
        assert response.json()["data_length"] == 1

