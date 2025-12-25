import pytest
import pandas as pd
import numpy as np
from unittest.mock import MagicMock, patch
from pipeline import StudentProfiler

class TestProfilerLogic:
    @pytest.fixture
    def sample_df(self):
        return pd.DataFrame({
            'ID': [1, 1, 2, 2, 3, 3, 4, 4],
            'Total': [10, 20, 30, 40, 50, 60, 70, 80],
            'is_fail': [1, 0, 0, 0, 1, 1, 0, 0],
            'Semester': [1, 2, 1, 2, 1, 2, 1, 2],
            'Practical': [5, 10, 15, 20, 25, 30, 35, 40],
            'Theoretical': [5, 10, 15, 20, 25, 30, 35, 40],
            'Status': ['Present', 'Absent', 'Present', 'Present', 'Present', 'Present', 'Present', 'Present']
        })

    def test_aggregate_by_student(self, sample_df):
        """
        Verify that student data is correctly aggregated
        """
        profiler = StudentProfiler(sample_df)
        profiler.aggregate_by_student()
        
        agg = profiler.student_features
        assert len(agg) == 2
        assert 'Failure_Rate' in agg.columns
        assert 'Absence_Count' in agg.columns

    def test_find_optimal_k(self, sample_df):
        """
        Test Elbow method logic (mocking KMeans and plots)
        """
        profiler = StudentProfiler(sample_df)
        profiler.aggregate_by_student()
        profiler.normalize_features()
        
        with patch('sklearn.cluster.KMeans') as mock_kmeans, \
             patch('matplotlib.pyplot.savefig'), \
             patch('matplotlib.pyplot.figure'), \
             patch('matplotlib.pyplot.close'):
            
            mock_inst = mock_kmeans.return_value
            mock_inst.fit.return_value = None
            mock_inst.inertia_ = 100
            
            profiler.find_optimal_k(range(2, 4))
            
            assert mock_inst.fit.called

    def test_cluster_students(self, sample_df):
        """
        Test Clustering logic
        """
        profiler = StudentProfiler(sample_df)
        profiler.aggregate_by_student()
        profiler.normalize_features()
        
        with patch('sklearn.cluster.KMeans') as mock_kmeans:
            inst = mock_kmeans.return_value
            inst.fit_predict.return_value = np.array([0, 1])
            
            profiler.cluster_students(n_clusters=2)
            
            assert 'Cluster' in profiler.student_features.columns
            assert len(profiler.student_features['Cluster'].unique()) == 2
