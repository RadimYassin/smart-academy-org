import pytest
from unittest.mock import MagicMock, patch
import requests
from services.ollama_wrapper import OllamaChat

@pytest.fixture
def ollama_client():
    return OllamaChat(model="test-model", base_url="http://mock-url")

@pytest.fixture
def mock_requests():
    with patch('requests.post') as mock:
        yield mock

def test_ollama_init():
    """Test initialization"""
    client = OllamaChat(model="llama3", base_url="http://test:11434/")
    assert client.model == "llama3"
    assert client.base_url == "http://test:11434" # Should strip trailing slash

def test_invoke_string_input(ollama_client, mock_requests):
    """Test invoke with string input"""
    mock_response = MagicMock()
    mock_response.json.return_value = {"response": "Mocked response"}
    mock_requests.return_value = mock_response
    
    result = ollama_client.invoke("Hello")
    
    assert result.content == "Mocked response"
    mock_requests.assert_called_once()
    args, kwargs = mock_requests.call_args
    assert kwargs['json']['prompt'] == "Hello"

def test_invoke_dict_input(ollama_client, mock_requests):
    """Test invoke with dict input"""
    mock_response = MagicMock()
    mock_response.json.return_value = {"response": "Mocked response"}
    mock_requests.return_value = mock_response
    
    # Test specific 'input' key
    ollama_client.invoke({"input": "Hello Dict"})
    assert mock_requests.call_args[1]['json']['prompt'] == "Hello Dict"
    
    # Test 'messages' key
    ollama_client.invoke({"messages": [{"role": "user", "content": "Hi"}]})
    assert "User: Hi" in mock_requests.call_args[1]['json']['prompt']

def test_invoke_langchain_messages(ollama_client, mock_requests):
    """Test invoke with LangChain message objects"""
    mock_response = MagicMock()
    mock_response.json.return_value = {"response": "Mocked response"}
    mock_requests.return_value = mock_response
    
    from langchain_core.messages import HumanMessage, SystemMessage
    
    messages = [
        SystemMessage(content="Be helpful"),
        HumanMessage(content="Hello")
    ]
    
    class MockInput:
        def to_messages(self):
            return messages
            
    ollama_client.invoke(MockInput())
    
    prompt = mock_requests.call_args[1]['json']['prompt']
    assert "System: Be helpful" in prompt
    assert "User: Hello" in prompt

def test_connection_error(ollama_client, mock_requests):
    """Test handling of connection error"""
    mock_requests.side_effect = requests.exceptions.ConnectionError
    
    with pytest.raises(ConnectionError, match="Impossible de se connecter à Ollama"):
        ollama_client.invoke("test")

def test_timeout_error(ollama_client, mock_requests):
    """Test handling of timeout error"""
    mock_requests.side_effect = requests.exceptions.Timeout
    
    with pytest.raises(TimeoutError, match="Le modèle Ollama met trop de temps"):
        ollama_client.invoke("test")

def test_langchain_methods(ollama_client):
    """Test compatibility methods"""
    assert ollama_client.bind() == ollama_client
    assert ollama_client.with_config({}) == ollama_client
