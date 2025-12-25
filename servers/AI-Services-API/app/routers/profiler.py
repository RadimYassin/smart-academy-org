"""
StudentProfiler Router - Student clustering and profiling endpoints
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Dict, List
import pandas as pd
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../src'))
from pipeline import StudentProfiler
from app.config import settings
from app.auth.jwt_middleware import get_current_user

router = APIRouter()


class ProfilerRequest(BaseModel):
    data_path: str | None = None  # Python 3.10+ union syntax for optional
    n_clusters: int = 4


class ProfilerResponse(BaseModel):
    status: str
    message: str
    total_students: int
    clusters: Dict[int, int]  # cluster_id: count
    output_path: str


@router.post("/profile", response_model=ProfilerResponse)
async def profile_students(request: ProfilerRequest, current_user: dict = Depends(get_current_user)):
    """
    Create student profiles and clusters
    
    - **data_path**: Path to cleaned data CSV (optional, uses default if not provided)
    - **n_clusters**: Number of clusters to create (default 4)
    """
    try:
        # Use provided path or default
        data_path = request.data_path or settings.DATA_PATH_CLEANED
        
        # Check if file exists
        if not os.path.exists(data_path):
            raise HTTPException(
                status_code=404,
                detail=f"Data file not found: {data_path}. Please run PrepaData first."
            )
        
        # Load cleaned data
        df_clean = pd.read_csv(data_path)
        print(f"📊 Loaded {len(df_clean)} records for profiling")
        
        # Run StudentProfiler
        profiler = StudentProfiler(df_clean)
        df_profiles = profiler.run_all(n_clusters=request.n_clusters)
        
        # Save profiles
        output_path = settings.DATA_PATH_PROFILES
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        df_profiles.to_csv(output_path, index=False)
        
        # Get cluster distribution
        cluster_counts = df_profiles['Cluster'].value_counts().to_dict()
        
        print(f"✅ Profiling complete: {len(df_profiles)} students, {len(cluster_counts)} clusters")
        
        return ProfilerResponse(
            status="success",
            message="Student profiling completed",
            total_students=len(df_profiles),
            clusters=cluster_counts,
            output_path=output_path
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in StudentProfiler: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def get_profiler_status():
    """Get StudentProfiler service status"""
    return {
        "service": "StudentProfiler",
        "status": "UP",
        "description": "Student clustering and profiling service",
        "algorithm": "K-Means + PCA",
        "capabilities": [
            "Aggregate student data",
            "Normalize features",
            "K-Means clustering (4 clusters default)",
            "PCA visualization",
            "Silhouette score validation"
        ]
    }
