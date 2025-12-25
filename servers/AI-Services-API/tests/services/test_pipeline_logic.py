import pytest
import pandas as pd
import sys
import os
from unittest.mock import MagicMock

# We need to ensure we can import the pipeline.
# Since pytest.ini adds 'available' paths, we should be able to import pipeline directly if src is in path.
# However, pipeline imports config, database etc. We might need to mock them if they fail.

# Use a fixture to mock external deps of pipeline BEFORE importing it if needed.
# But PrepaData logic is mostly pandas manipulation, so it might be fine.

from pipeline import PrepaData

class TestPrepaDataLogic:
    def test_recalculate_total(self):
        """
        Test that Total is correctly recalculated from Practical + Theoretical
        """
        df = pd.DataFrame({
            'Practical': [10, 20],
            'Theoretical': [30, 40],
            'Total': [None, None], # Initial values must be None for fillna to work
            'Subject': ['A', 'B'],
            'Status': ['Present', 'Present']
        })
        
        preparer = PrepaData(df)
        preparer.recalculate_total()
        
        result_df = preparer.get_clean_data()
        
        assert result_df.loc[0, 'Total'] == 40
        assert result_df.loc[1, 'Total'] == 60

    def test_create_target_variable(self):
        """
        Test specific success/fail logic based on threshold and status.
        """
        df = pd.DataFrame({
            'Total': [5, 15, 20],
            'Status': ['Present', 'Present', 'Absent'],
            'Subject': ['A', 'A', 'A'],
            'Practical': [0,0,0],
            'Theoretical': [0,0,0]
        })
        
        preparer = PrepaData(df)
        preparer.create_target_variable(threshold=10)
        
        result_df = preparer.get_clean_data()
        
        # Case 1: Total 5 < 10 => Fail (1)
        assert result_df.loc[0, 'is_fail'] == 1
        
        # Case 2: Total 15 > 10, Present => Success (0)
        assert result_df.loc[1, 'is_fail'] == 0
        
        # Case 3: Absent => Fail (1)
        assert result_df.loc[2, 'is_fail'] == 1
