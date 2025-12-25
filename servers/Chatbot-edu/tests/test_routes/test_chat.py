from fastapi import status

def test_ask_question_success(client, mock_rag_service):
    """
    Test the /chat/ask endpoint with a valid question.
    """
    # Arrange
    question_text = "What is a class?"
    mock_response = {
        "answer": "A class is a blueprint for creating objects.",
        "sources": [{"source_file": "course.pdf", "page": 1, "content": "Class def..."}],
        "model_used": "gpt-4",
        "num_sources": 1
    }
    mock_rag_service.return_value = mock_response

    payload = {"question": question_text}

    # Act
    response = client.post("/chat/ask", json=payload)

    # Assert
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["answer"] == mock_response["answer"]
    assert data["num_sources"] == 1
    # Verify the service was called with the correct argument
    mock_rag_service.assert_called_once_with(question_text)

def test_ask_question_validation_error(client):
    """
    Test the /chat/ask endpoint with an invalid question (too short).
    Should return 422 Unprocessable Entity (Pydantic validation).
    """
    # Arrange
    payload = {"question": "Hi"} # Length 2, min is 3

    # Act
    response = client.post("/chat/ask", json=payload)

    # Assert
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_ask_question_faiss_missing_error(client, mock_rag_service):
    """
    Test the /chat/ask endpoint when the service raises FileNotFoundError (FAISS index missing).
    """
    # Arrange
    mock_rag_service.side_effect = FileNotFoundError("Index missing")
    payload = {"question": "Any question"}

    # Act
    response = client.post("/chat/ask", json=payload)

    # Assert
    assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
    assert "L'index de recherche n'est pas disponible" in response.json()["detail"]
