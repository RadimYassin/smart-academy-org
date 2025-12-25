"""
RecoBuilder Router - AI-powered recommendation endpoints
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Dict
import pandas as pd
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../src'))
from recobuilder import RecoBuilder
from app.config import settings
from app.auth.jwt_middleware import get_current_user

router = APIRouter()


class RecommendationRequest(BaseModel):
    student_ids: List[int]
    resources_path: str = "../data/resources/educational_resources.json"


class RecommendationResponse(BaseModel):
    status: str
    message: str
    total_recommendations: int
    output_path: str


@router.post("/generate", response_model=RecommendationResponse)
async def generate_recommendations(request: RecommendationRequest, current_user: dict = Depends(get_current_user)):
    """
    Generate personalized recommendations for students
    
    - **student_ids**: List of student IDs to generate recommendations for
    - **resources_path**: Path to educational resources JSON
    """
    try:
        # Check if OpenAI API key is configured
        if not settings.OPENAI_API_KEY or settings.OPENAI_API_KEY == "":
            raise HTTPException(
                status_code=503,
                detail="OpenAI API key not configured. Please set OPENAI_API_KEY in .env file."
            )
        
        # Check if required data files exist
        if not os.path.exists(settings.DATA_PATH_CLEANED):
            raise HTTPException(
                status_code=404,
                detail="Cleaned data not found. Please run PrepaData first."
            )
        
        if not os.path.exists(settings.DATA_PATH_PROFILES):
            raise HTTPException(
                status_code=404,
                detail="Student profiles not found. Please run StudentProfiler first."
            )
        
        # Load data
        df_clean = pd.read_csv(settings.DATA_PATH_CLEANED)
        df_profiles = pd.read_csv(settings.DATA_PATH_PROFILES)
        
        print(f"📊 Generating recommendations for {len(request.student_ids)} students")
        
        # Initialize RecoBuilder
        recommender = RecoBuilder()
        
        # Generate recommendations using run_all method
        # This will load resources, build FAISS index, analyze profiles, and generate recommendations
        recommendations_list = recommender.run_all(
            resources_path=request.resources_path,
            df_clean=df_clean,
            df_profiles=df_profiles,
            sample_students=request.student_ids
        )
        
        # Convert recommendations list to DataFrame for saving
        if recommendations_list:
            recommendations_df = pd.DataFrame(recommendations_list)
        else:
            recommendations_df = pd.DataFrame()
        
        # Save recommendations
        output_path = os.path.join(settings.OUTPUTS_PATH, "recommendations.csv")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        if not recommendations_df.empty:
            recommendations_df.to_csv(output_path, index=False)
            print(f"✅ Generated {len(recommendations_df)} recommendations")
        else:
            print("⚠️ No recommendations generated")
        
        return RecommendationResponse(
            status="success",
            message="Recommendations generated successfully",
            total_recommendations=len(recommendations_list),
            output_path=output_path
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in RecoBuilder: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def get_recommender_status():
    """Get RecoBuilder service status"""
    openai_configured = (
        settings.OPENAI_API_KEY and 
        settings.OPENAI_API_KEY != "your_openai_api_key_here"
    )
    
    return {
        "service": "RecoBuilder",
        "status": "UP",
        "description": "AI-powered recommendation service",
        "technologies": ["OpenAI GPT-4", "OpenAI Embeddings", "FAISS"],
        "openai_configured": openai_configured,
        "capabilities": [
            "Semantic similarity search (FAISS)",
            "GPT-4 personalized action plans",
            "Risk-based resource recommendations",
            "Top-3 resource suggestions per student"
        ]
    }
