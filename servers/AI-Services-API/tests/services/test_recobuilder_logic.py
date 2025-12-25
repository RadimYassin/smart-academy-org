import pytest
from unittest.mock import MagicMock, patch, mock_open
import sys
import numpy as np

# Mock dependencies before import
sys.modules['openai'] = MagicMock()
sys.modules['faiss'] = MagicMock()

from recobuilder import RecoBuilder

class TestRecoBuilderLogic:
    def test_init_check(self):
        """Test API Key validation"""
        with patch('os.getenv', return_value=None):
            with pytest.raises(ValueError):
                RecoBuilder(api_key=None)
        
        with patch('os.getenv', return_value="sk-123"):
            rb = RecoBuilder()
            assert rb.client is not None

    def test_build_faiss_index(self):
        """Test embedding generation and indexing mock"""
        rb = RecoBuilder(api_key="test")
        rb.resources = [{"title": "Test", "description": "Desc", "subject": "Math", "type": "Video", "difficulty": "Easy"}]
        rb.client = MagicMock()
        
        # Mock embedding response
        mock_resp = MagicMock()
        mock_embedding = MagicMock()
        mock_embedding.embedding = [0.1] * 1536
        mock_resp.data = [mock_embedding]
        rb.client.embeddings.create.return_value = mock_resp
        
        rb.build_faiss_index()
        
        assert rb.embeddings is not None
        assert rb.faiss_index is not None

    def test_search_similar_resources(self):
        """Test search logic"""
        rb = RecoBuilder(api_key="test")
        rb.faiss_index = MagicMock()
        rb.faiss_index.search.return_value = (np.array([[0.1]]), np.array([[0]]))
        rb.resources = [{"title": "R1", "subject": "Math"}]
        rb.client = MagicMock()
        rb.client.embeddings.create.return_value.data[0].embedding = [0.1] * 1536
        
        results = rb.search_similar_resources("query")
        assert len(results) == 1
        assert results[0]['title'] == "R1"

    def test_generate_recommendations(self):
        """Test GPT call wrapping"""
        rb = RecoBuilder(api_key="test")
        rb.search_similar_resources = MagicMock(return_value=[])
        
        # Mock GPT response
        rb.client = MagicMock()
        rb.client.chat.completions.create.return_value.choices[0].message.content = "Action Plan"
        
        profile = {
            'student_id': 1,
            'weak_subjects': [{'Subject': 'Math', 'Failure_Rate': 0.8}],
            'risk_level': 'High',
            'avg_score': 50,
            'risk_emoji': '🔴',
            'failure_rate': 0.8
        }
        
        recs = rb.generate_recommendations(profile)
        
        assert recs['student_id'] == 1
        assert len(recs['recommendations']) == 1
