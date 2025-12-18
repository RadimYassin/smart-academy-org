"""
JWT Authentication for Chatbot-edu
Validates tokens from Smart Academy Gateway
"""
import jwt
from fastapi import Header, HTTPException, status
import os
import logging

logger = logging.getLogger(__name__)

JWT_SECRET = os.getenv("JWT_SECRET", "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970")
JWT_ALGORITHM = "HS256"

def verify_token(authorization: str = Header(None)) -> dict:
    """
    Verify JWT token from Authorization header
    
    Args:
        authorization: Bearer token from header
        
    Returns:
        dict: Decoded token payload with userId and roles
        
    Raises:
        HTTPException: If token is invalid or missing
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )
    
    if not authorization.startsWith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization format. Use: Bearer <token>"
        )
    
    token = authorization[7:]  # Remove "Bearer "
    
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        logger.info(f"Token verified for user: {payload.get('userId')}")
        return payload
    except jwt.ExpiredSignatureError:
        logger.warning("Token expired")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired"
        )
    except jwt.InvalidTokenError as e:
        logger.error(f"Invalid token: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

def get_current_user(authorization: str = Header(None)) -> dict:
    """
    Get current user info from JWT token
    
    Args:
        authorization: Bearer token from header
        
    Returns:
        dict: User info with userId, roles, and email
    """
    payload = verify_token(authorization)
    return {
        "userId": payload.get("userId"),
        "roles": payload.get("roles", []),
        "email": payload.get("sub")
    }

def require_role(required_roles: list):
    """
    Dependency to check if user has required role
    
    Args:
        required_roles: List of allowed roles (e.g., ["ROLE_STUDENT", "ROLE_TEACHER"])
    """
    def role_checker(authorization: str = Header(None)):
        user = get_current_user(authorization)
        user_roles = user.get("roles", [])
        
        if not any(role in user_roles for role in required_roles):
            logger.warning(f"Access denied for user {user.get('userId')} - Required: {required_roles}, Has: {user_roles}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required roles: {required_roles}"
            )
        return user
    
    return role_checker
