import pytest
from unittest.mock import patch, MagicMock
from auth.eureka_reg import register_with_eureka
import os

@patch("py_eureka_client.eureka_client.init")
def test_register_with_eureka_success(mock_init):
    # Set environment variable
    with patch.dict(os.environ, {"EUREKA_INSTANCE_HOSTNAME": "test-host"}):
        register_with_eureka(app_name="TEST-APP", port=9999, eureka_server="http://eureka:8761/eureka")
        
        mock_init.assert_called_once_with(
            eureka_server="http://eureka:8761/eureka",
            app_name="TEST-APP",
            instance_port=9999,
            instance_host="test-host",
            renewal_interval_in_secs=30,
            duration_in_secs=90
        )

@patch("py_eureka_client.eureka_client.init")
def test_register_with_eureka_failure(mock_init):
    mock_init.side_effect = Exception("Connection Refused")
    
    # This should not raise an exception, just log it
    register_with_eureka()
    
    mock_init.assert_called_once()

@patch("py_eureka_client.eureka_client.init")
def test_register_with_eureka_default_host(mock_init):
    # Remove env var if exists
    with patch.dict(os.environ, {}, clear=False):
        if "EUREKA_INSTANCE_HOSTNAME" in os.environ:
            del os.environ["EUREKA_INSTANCE_HOSTNAME"]
            
        register_with_eureka()
        
        # Check if default "localhost" is used
        args, kwargs = mock_init.call_args
        assert kwargs["instance_host"] == "localhost"
