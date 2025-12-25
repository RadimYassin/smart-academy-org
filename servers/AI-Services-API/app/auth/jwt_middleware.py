"""
JWT Authentication Middleware for AI Services
Validates tokens from Smart Academy microservices ecosystem
"""
from fastapi import Header, HTTPException, status, Depends
from typing import Optional
import jwt
import base64
from app.config import settings

def verify_jwt_token(authorization: Optional[str] = Header(None)) -> dict:
    """
    Verify JWT token from Authorization header
    
    Args:
        authorization: Bearer token from header
        
    Returns:
        dict: Decoded token payload
        
    Raises:
        HTTPException: If token is invalid or missing
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization format. Use: Bearer <token>",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = authorization[7:]  # Remove "Bearer "
    
    try:
        # IMPORTANT: Java (User-Management) uses BASE64.decode() on the secret
        # We must do the same to validate tokens correctly
        jwt_secret_decoded = base64.b64decode(settings.JWT_SECRET)
        
        payload = jwt.decode(
            token, 
            jwt_secret_decoded,  # Use decoded secret
            algorithms=[settings.JWT_ALGORITHM]
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.InvalidTokenError as e:
        # Log the error for debugging
        print(f"JWT validation error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )

def get_current_user(token_payload: dict = Depends(verify_jwt_token)) -> dict:
    """
    Extract current user info from token payload
    
    Returns:
        dict: User information (userId, email, roles)
    """
    return {
        "userId": token_payload.get("userId") or token_payload.get("sub"),
        "email": token_payload.get("email") or token_payload.get("sub"),
        "roles": token_payload.get("roles", []),
    }

def require_role(allowed_roles: list):
    """
    Dependency to check if user has required role
    
    Args:
        allowed_roles: List of allowed roles (e.g., ["ROLE_TEACHER", "ROLE_ADMIN"])
        
    Returns:
        Function that validates user has one of the required roles
    """
    def role_checker(current_user: dict = Depends(get_current_user)):
        user_roles = current_user.get("roles", [])
        if not any(role in user_roles for role in allowed_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required roles: {allowed_roles}"
            )
        return current_user
    return role_checker
