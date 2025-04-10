from fastapi import Depends, HTTPException, status
from fastapi.security import APIKeyHeader
from os import environ as env

api_key = env.get("API_KEY")

api_key_header = APIKeyHeader(name="x-api-key", auto_error=True)


def verify_api_key(auth_header: str = Depends(api_key_header)):
    if auth_header != api_key:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="not authorized"
        )
