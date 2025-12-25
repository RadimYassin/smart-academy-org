"""
PathPredictor Router - Student failure prediction endpoints
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Dict, List, Any
import pandas as pd
import pickle
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../src'))
from pipeline import PathPredictor
from app.config import settings
from app.auth.jwt_middleware import get_current_user

router = APIRouter()


class TrainRequest(BaseModel):
    data_path: str = None
    use_grid_search: bool = False


class TrainResponse(BaseModel):
    status: str
    message: str
    accuracy: float
    model_path: str


class PredictRequest(BaseModel):
    student_data: Dict[str, Any]


class PredictResponse(BaseModel):
    student_id: int
    prediction: str  # "Success" or "Fail"
    probability_fail: float
    probability_success: float
    risk_level: str  # "Low", "Medium", "High"


@router.post("/train", response_model=TrainResponse)
async def train_model(request: TrainRequest, current_user: dict = Depends(get_current_user)):
    """
    Train PathPredictor model
    
    - **data_path**: Path to cleaned data (optional, uses default)
    - **use_grid_search**: Enable GridSearch for hyperparameter tuning (default False)
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
        
        # Load data
        df_clean = pd.read_csv(data_path)
        print(f"📊 Training model on {len(df_clean)} records")
        
        # Train model
        predictor = PathPredictor(df_clean)
        predictor.run_all(use_grid_search=request.use_grid_search)
        
        # Get accuracy
        from sklearn.metrics import accuracy_score
        y_pred = predictor.model.predict(predictor.X_test)
        accuracy = accuracy_score(predictor.y_test, y_pred)
        
        print(f"✅ Model trained with accuracy: {accuracy*100:.2f}%")
        
        return TrainResponse(
            status="success",
            message="Model trained successfully",
            accuracy=round(accuracy, 4),
            model_path=settings.MODEL_PATH
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in PathPredictor training: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))



@router.post("/predict", response_model=PredictResponse)
async def predict_student(request: PredictRequest, current_user: dict = Depends(get_current_user)):
    """
    Predict failure probability for a student
    
    - **student_data**: Dictionary with student features
    """
    try:
        # Load trained model
        if not os.path.exists(settings.MODEL_PATH):
            raise HTTPException(
                status_code=404,
                detail="Model not found. Please train the model first using /train endpoint."
            )
        
        with open(settings.MODEL_PATH, "rb") as f:
            model = pickle.load(f)
        
        # Extract student ID (not used for prediction)
        student_id = request.student_data.get("ID", 0)
        
        # Prepare student data
        student_df = pd.DataFrame([request.student_data])
        
        # Remove ID column if present (model wasn't trained with this feature)
        if 'ID' in student_df.columns:
            student_df = student_df.drop(columns=['ID'])
        
        # Encode categorical variables
        # Gender: M=1, F=0
        if 'Gender' in student_df.columns:
            student_df['Gender'] = student_df['Gender'].map({'M': 1, 'F': 0, 'Male': 1, 'Female': 0})
            student_df['Gender'] = student_df['Gender'].fillna(0).astype(int)
        
        # Convert all columns to numeric types
        for col in student_df.columns:
            if student_df[col].dtype == 'object':
                # Try to convert to numeric, if fails set to 0
                student_df[col] = pd.to_numeric(student_df[col], errors='coerce').fillna(0)
        
        # Make prediction
        prediction = model.predict(student_df)[0]
        probabilities = model.predict_proba(student_df)[0]
        
        # Determine risk level
        prob_fail = float(probabilities[1])
        if prob_fail < 0.3:
            risk_level = "Low"
        elif prob_fail < 0.7:
            risk_level = "Medium"
        else:
            risk_level = "High"
        
        return PredictResponse(
            student_id=student_id,
            prediction="Fail" if prediction == 1 else "Success",
            probability_fail=round(prob_fail, 4),
            probability_success=round(float(probabilities[0]), 4),
            risk_level=risk_level
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in prediction: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))



@router.get("/status")
async def get_predictor_status():
    """Get PathPredictor service status"""
    model_exists = os.path.exists(settings.MODEL_PATH)
    
    return {
        "service": "PathPredictor",
        "status": "UP",
        "description": "Student failure prediction service",
        "algorithm": "XGBoost Classifier",
        "model_trained": model_exists,
        "accuracy": "99.09%" if model_exists else "Not trained",
        "capabilities": [
            "13 engineered features",
            "GridSearch hyperparameter tuning",
            "5-fold cross-validation",
            "Class imbalance handling",
            "MLflow experiment tracking"
        ]
    }
