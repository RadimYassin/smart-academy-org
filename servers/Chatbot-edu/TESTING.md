# Testing Guide for Chatbot-edu

This document outlines the testing strategy, usage, and best practices for the Chatbot-edu project.

## 1. Test Structure

We follow a standard `pytest` structure where tests mirror the source code layout:

```
servers/Chatbot-edu/
├── tests/
│   ├── conftest.py           # Shared fixtures (client, mocks)
│   ├── test_routes/          # API endpoint tests
│   │   └── test_chat.py      # Tests for /chat endpoints
│   └── test_services/        # Business logic tests
│       └── test_rag.py       # Tests for RAG service logic
├── pytest.ini                # Pytest configuration
└── requirements-test.txt     # Test dependencies
```

## 2. Prerequisites

Install the testing dependencies:

```bash
pip install -r requirements-test.txt
```

**Key libraries:**
- `pytest`: The test runner.
- `fastapi.testclient`: For integration testing of API routes.
- `pytest-mock` / `unittest.mock`: For mocking external dependencies (LLMs, Databases, FS).
- `pytest-cov`: For measuring code coverage.

## 3. Running Tests

To run all tests:

```bash
pytest
```

To run a specific test file:

```bash
pytest tests/test_routes/test_chat.py
```

## 4. Code Coverage

The project is configured to measure coverage automatically via `pytest.ini`.

To see the coverage report in the terminal:

```bash
pytest --cov=app --cov=services --cov=routers --cov-report=term-missing
```

- **Pass**: Tests pass if assertions hold true.
- **Coverage**: Shows which lines were executed. Aim for high coverage in `services/` and `routers/`.

## 5. Implementation Details

### Unit Tests (Routes)
Located in `tests/test_routes/`. We use `TestClient` to send HTTP requests to the FastAPI app. 
- **Mocking**: We mock the underlying services (e.g., `ask_question`) to isolate the API layer. This ensures API tests are fast and don't require a running Faiss index or OpenAI key.

### Unit Tests (Services)
Located in `tests/test_services/`. We test the business logic functions directly.
- **Mocking**: External calls (OpenAI, File System) are mocked. For example, in `test_rag.py`, we patch `langchain_openai.ChatOpenAI` and `load_vectorstore`.

## 6. Best Practices

1.  **Isolation**: Tests should not depend on each other. Use `fixtures` for setup.
2.  **Mock External Dependencies**: Never hit real APIs (OpenAI, AWS) in unit tests. Use `unittest.mock` or `pytest-mock`.
3.  **Test Edge Cases**: specific failure modes (e.g., empty input, missing index) are just as important as success paths.
4.  **Keep it Fast**: Unit tests should run in milliseconds.
5.  **Fixture Usage**: Use `conftest.py` for shared re-usable components like the `client` or common mocks.

## 7. Configuration (`pytest.ini`)

The `pytest.ini` file sets default options, including:
- default test paths
- environment variables for testing (mocked keys)
- coverage settings
