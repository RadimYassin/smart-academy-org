"""
PrepaData Router - Data cleaning and normalization endpoints
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from pydantic import BaseModel
from typing import Dict, Any
import pandas as pd
import sys
import os
from io import BytesIO

# Add src to path to import existing services
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../src'))

from pipeline import PrepaData
from app.config import settings
from app.auth.jwt_middleware import get_current_user

router = APIRouter()


class PrepDataRequest(BaseModel):
    threshold: float = 50.0


class PrepDataResponse(BaseModel):
    status: str
    message: str
    records_processed: int
    output_path: str


@router.post("/clean", response_model=PrepDataResponse)
async def clean_data(file: UploadFile = File(...), threshold: float = settings.DEFAULT_FAIL_THRESHOLD, current_user: dict = Depends(get_current_user)):
    """
    Clean and prepare student data
    
    - **file**: CSV file with raw student data
    - **threshold**: Fail threshold (default 50.0)
    """
    try:
        # Read uploaded CSV
        contents = await file.read()
        df = pd.read_csv(BytesIO(contents))
        
        print(f"📊 Received data: {len(df)} rows, {len(df.columns)} columns")
        
        # Run PrepaData
        preparer = PrepaData(df)
        df_clean = preparer.run_all(threshold=threshold)
        
        # Save to processed folder
        output_path = settings.DATA_PATH_CLEANED
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        df_clean.to_csv(output_path, index=False)
        
        print(f"✅ Data cleaned: {len(df_clean)} records saved to {output_path}")
        
        return PrepDataResponse(
            status="success",
            message="Data cleaned successfully",
            records_processed=len(df_clean),
            output_path=output_path
        )
        
    except Exception as e:
        print(f"❌ Error in PrepaData: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def get_prepadata_status():
    """Get PrepaData service status"""
    return {
        "service": "PrepaData",
        "status": "UP",
        "description": "Data cleaning and normalization service",
        "capabilities": [
            "Recalculate total scores",
            "Encode categorical variables",
            "Create binary failure targets",
            "Handle ~160K records in 10 seconds"
        ]
    }
