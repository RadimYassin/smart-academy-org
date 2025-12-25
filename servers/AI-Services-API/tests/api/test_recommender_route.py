import pytest
import pandas as pd
from unittest.mock import MagicMock, patch, mock_open

def test_generate_recommendations_endpoint(client, mock_auth):
    """
    Test POST /api/recommender/generate
    """
    # Mock RecoBuilder class
    with patch('app.routers.recommender.RecoBuilder') as mock_rb_cls, \
         patch('pandas.read_csv') as mock_read_csv, \
         patch('os.path.exists', return_value=True), \
         patch('os.makedirs'):
         
        # Mock student profiles dataframe
        mock_read_csv.return_value = pd.DataFrame({'ID': [1]})
        
        # Mock RecoBuilder instance
        mock_instance = mock_rb_cls.return_value
        mock_instance.generate_recommendations.return_value = [{'student_id': 1, 'recs': []}]
        
        response = client.post("/api/recommender/generate", json={
            "student_ids": [1]
        })
        
        assert response.status_code == 200
        assert response.json()["total_recommendations"] == 1

def test_recommend_at_risk_endpoint(client, mock_auth):
    """
    Test POST /api/recommender/recommend-at-risk-from-lms
    """
    # Mock internal dependencies: httpx, xgboost models, openai
    mock_model = MagicMock()
    mock_model.predict.return_value = [1]
    mock_model.predict_proba.return_value = [[0.1, 0.9]] # High risk
    
    with patch('httpx.AsyncClient.get') as mock_get, \
         patch('builtins.open', mock_open(read_data=b"data")), \
         patch('pickle.load', return_value=mock_model), \
         patch('app.config.settings.OPENAI_API_KEY', new="sk-test"):
         
        # Mock LMS Response
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [{
            'studentId': 1, 'studentName': 'Test', 
            'practical': 10, 'theoretical': 10, 'total': 20
        }]
        mock_get.return_value = mock_resp
        
        # Mock OpenAI Client inside the route
        with patch('openai.OpenAI') as mock_openai:
            mock_openai.return_value.chat.completions.create.return_value.choices[0].message.content = '["Rec 1"]'
            
            response = client.post("/api/recommender/recommend-at-risk-from-lms")
            
            assert response.status_code == 200
            data = response.json()
            assert data["at_risk_count"] == 1
            assert data["recommendations"][0]["student_id"] == 1

def test_get_recommender_status(client):
    """
    Test GET /api/recommender/status
    """
    response = client.get("/api/recommender/status")
    assert response.status_code == 200
    assert response.json()["status"] == "UP"
    assert "OpenAI GPT-4" in response.json()["technologies"]

def test_recommend_at_risk_fallback(client, mock_auth):
    """
    Test fallback to rule-based recommendations when OpenAI key is missing
    """
    mock_model = MagicMock()
    mock_model.predict.return_value = [1]
    mock_model.predict_proba.return_value = [[0.1, 0.9]]
    
    with patch('httpx.AsyncClient.get') as mock_get, \
         patch('builtins.open', mock_open(read_data=b"data")), \
         patch('pickle.load', return_value=mock_model), \
         patch('app.config.settings.OPENAI_API_KEY', new=""):
         
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [{'studentId': 1, 'subject': 'X', 'practical': 0, 'theoretical': 0, 'total': 0}]
        mock_get.return_value = mock_resp
        
        response = client.post("/api/recommender/recommend-at-risk-from-lms")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["recommendations"]) > 0
        # ai_generated key might be missing in fallback according to code analysis


