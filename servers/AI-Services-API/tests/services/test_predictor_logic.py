import pytest
import pandas as pd
import numpy as np
from unittest.mock import MagicMock, patch
import sys

# Mock xgboost before importing pipeline
sys.modules['xgboost'] = MagicMock()

from pipeline import PathPredictor

class TestPathPredictorLogic:
    @pytest.fixture
    def sample_df(self):
        return pd.DataFrame({
            'Subject_Encoded': [1, 2, 1, 2, 1, 2, 1, 2],
            'Semester': [1, 1, 2, 2, 1, 1, 2, 2],
            'Practical': [10, 15, 12, 14, 10, 15, 12, 14],
            'Theoretical': [20, 30, 25, 28, 20, 30, 25, 28],
            'Total': [30, 45, 37, 42, 30, 45, 37, 42],
            'MajorYear': [1, 1, 1, 1, 1, 1, 1, 1],
            'Major': ['CS', 'CS', 'CS', 'CS', 'CS', 'CS', 'CS', 'CS'],
            'is_fail': [0, 0, 1, 1, 0, 0, 1, 1],
            'ID': [1, 1, 2, 2, 3, 3, 4, 4] # Needed for lag features
        })

    def test_prepare_features(self, sample_df):
        """
        Test that feature engineering creates expected columns
        """
        predictor = PathPredictor(sample_df)
        predictor.prepare_features()
        
        # Check if new features exist
        assert 'Practical_Theoretical_Ratio' in predictor.df.columns
        assert 'Total_Deviation' in predictor.df.columns
        assert 'Subject_Relative_Performance' in predictor.df.columns
        assert 'Major_Encoded' in predictor.df.columns
        
        # Check dimensions of train/test split
        assert predictor.X_train is not None
        assert predictor.y_train is not None

    def test_train_model_logic(self, sample_df):
        """
        Test the training flow (mocking the actual XGBoost fitting)
        """
        predictor = PathPredictor(sample_df)
        predictor.prepare_features()
        
        # Mocking the internal model
        with patch('xgboost.XGBClassifier') as mock_xgb:
            mock_instance = mock_xgb.return_value
            mock_instance.fit.return_value = None
            
            # Using custom config to avoid GridSearch overhead in unit test
            predictor.train_model(use_grid_search=False)
            
            # Verify fit was called
            mock_instance.fit.assert_called_once()
            assert predictor.model is not None

    def test_predict(self, sample_df):
        """
        Test prediction wrapper
        """
        predictor = PathPredictor(sample_df)
        predictor.model = MagicMock()
        predictor.model.predict.return_value = np.array([0, 1])
        predictor.X_test = pd.DataFrame({'col': [1, 2]})
        predictor.y_test = pd.Series([0, 1])
        
        # Calling evaluate just to see if it runs without error
        # We need to mock matplotlib to avoid plot generation errors during test
        with patch('matplotlib.pyplot.savefig'), patch('matplotlib.pyplot.show'):
             predictor.evaluate_model()
             
        predictor.model.predict.assert_called()
