import pytest
from fastapi import HTTPException, status
from auth.jwt_utils import verify_token, get_current_user, require_role, JWT_SECRET, JWT_ALGORITHM
import jwt
import time
import base64

def create_token(payload: dict, expires_in=3600):
    to_encode = payload.copy()
    expire = time.time() + expires_in
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)

def test_verify_token_success():
    payload = {"userId": "123", "sub": "test@example.com", "roles": ["ROLE_USER"]}
    token = create_token(payload)
    authorization = f"Bearer {token}"
    
    decoded = verify_token(authorization)
    assert decoded["userId"] == "123"
    assert decoded["sub"] == "test@example.com"

def test_verify_token_missing_header():
    with pytest.raises(HTTPException) as exc:
        verify_token(None)
    assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED
    assert "Authorization header missing" in exc.value.detail

def test_verify_token_invalid_format():
    with pytest.raises(HTTPException) as exc:
        verify_token("InvalidTokenFormat")
    assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED
    assert "Invalid authorization format" in exc.value.detail

def test_verify_token_expired():
    payload = {"userId": "123"}
    token = create_token(payload, expires_in=-10)
    authorization = f"Bearer {token}"
    
    with pytest.raises(HTTPException) as exc:
        verify_token(authorization)
    assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED
    assert "Token expired" in exc.value.detail

def test_verify_token_invalid_signature():
    payload = {"userId": "123"}
    token = jwt.encode(payload, "wrong_secret", algorithm=JWT_ALGORITHM)
    authorization = f"Bearer {token}"
    
    with pytest.raises(HTTPException) as exc:
        verify_token(authorization)
    assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED
    assert "Invalid token" in exc.value.detail

def test_get_current_user():
    payload = {"userId": "123", "sub": "test@example.com", "roles": ["ROLE_STUDENT"]}
    token = create_token(payload)
    authorization = f"Bearer {token}"
    
    user = get_current_user(authorization)
    assert user["userId"] == "123"
    assert user["email"] == "test@example.com"
    assert "ROLE_STUDENT" in user["roles"]

def test_require_role_success():
    payload = {"roles": ["ROLE_TEACHER"]}
    token = create_token(payload)
    authorization = f"Bearer {token}"
    
    role_checker = require_role(["ROLE_TEACHER", "ROLE_ADMIN"])
    user = role_checker(authorization)
    assert "ROLE_TEACHER" in user["roles"]

def test_require_role_forbidden():
    payload = {"roles": ["ROLE_STUDENT"]}
    token = create_token(payload)
    authorization = f"Bearer {token}"
    
    role_checker = require_role(["ROLE_TEACHER"])
    with pytest.raises(HTTPException) as exc:
        role_checker(authorization)
    assert exc.value.status_code == status.HTTP_403_FORBIDDEN
    assert "Insufficient permissions" in exc.value.detail
