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
