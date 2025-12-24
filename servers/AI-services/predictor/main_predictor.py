"""
PathPredictor Microservice - FastAPI Application
Risk Prediction Service using XGBoost
Port: 8003
"""

import sys
import os
import logging
import pickle
from contextlib import asynccontextmanager
from typing import Dict, Any, List, Optional
import pandas as pd

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from shared.eureka_client import register_with_eureka
from src.pipeline import PathPredictor

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

SERVICE_PORT = int(os.getenv('SERVICE_PORT', 8003))
EUREKA_SERVER = os.getenv('EUREKA_SERVER_URL', 'http://localhost:8761/eureka')
MODEL_PATH = '/app/models/xgboost_model.pkl'

# Global model variable
trained_model = None


# Pydantic models
class TrainModelRequest(BaseModel):
    data: list[dict]
    use_grid_search: bool = False


class TrainModelResponse(BaseModel):
    status: str
    message: str
    metrics: Dict[str, Any]


class PredictRequest(BaseModel):
    features: dict


class PredictBatchRequest(BaseModel):
    data: list[dict]


class PredictResponse(BaseModel):
    student_id: Optional[int]
    prediction: int
    probability: float
    risk_level: str


class HealthResponse(BaseModel):
    status: str
    service: str
    port: int
    model_loaded: bool


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    global trained_model
    
    logger.info("=" * 70)
    logger.info("🚀 PathPredictor Service Starting")
    logger.info("=" * 70)
    logger.info(f"Port: {SERVICE_PORT}")
    
    # Try to load existing model
    if os.path.exists(MODEL_PATH):
        try:
            with open(MODEL_PATH, 'rb') as f:
                trained_model = pickle.load(f)
            logger.info("✅ Pre-trained model loaded successfully")
        except Exception as e:
            logger.warning(f"⚠️  Failed to load model: {e}")
    
    register_with_eureka(
        app_name="pathpredictor-service",
        port=SERVICE_PORT,
        eureka_server=EUREKA_SERVER
    )
    
    # Start heartbeat task
    import asyncio
    from shared.eureka_client import send_heartbeat
    import socket
    
    hostname = socket.gethostname()
    instance_id = f"{hostname}:pathpredictor-service:{SERVICE_PORT}"
    heartbeat_task = None
    
    async def send_heartbeats():
        """Send periodic heartbeats to Eureka"""
        while True:
            try:
                await asyncio.sleep(30)
                send_heartbeat("pathpredictor-service", instance_id, EUREKA_SERVER)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Heartbeat error: {e}")
    
    heartbeat_task = asyncio.create_task(send_heartbeats())
    
    yield
    
    # Shutdown
    if heartbeat_task:
        heartbeat_task.cancel()
        try:
            await heartbeat_task
        except asyncio.CancelledError:
            pass
    logger.info("🛑 PathPredictor Service Shutting Down")


app = FastAPI(
    title="PathPredictor Service",
    description="Risk Prediction Microservice using XGBoost",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "PathPredictor",
        "version": "1.0.0",
        "status": "running",
        "model_loaded": trained_model is not None,
        "endpoints": {
            "health": "/health",
            "train": "/api/v1/train-model",
            "predict": "/api/v1/predict",
            "predict_batch": "/api/v1/predict-batch",
            "metrics": "/api/v1/model-metrics"
        }
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        service="pathpredictor-service",
        port=SERVICE_PORT,
        model_loaded=trained_model is not None
    )


@app.post("/api/v1/train-model", response_model=TrainModelResponse)
async def train_model(request: TrainModelRequest):
    """
    Train XGBoost model for risk prediction
    """
    global trained_model
    
    try:
        logger.info(f"Training model with {len(request.data)} records")
        
        df = pd.DataFrame(request.data)
        
        predictor = PathPredictor(df)
        model = predictor.run_all(use_grid_search=request.use_grid_search)
        
        # Save model
        os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
        with open(MODEL_PATH, 'wb') as f:
            pickle.dump(model, f)
        
        trained_model = model
        
        # Get metrics
        y_pred = model.predict(predictor.X_test)
        accuracy = (y_pred == predictor.y_test).mean()
        
        metrics = {
            "accuracy": float(accuracy),
            "train_size": len(predictor.X_train),
            "test_size": len(predictor.X_test),
            "features": predictor.feature_names
        }
        
        logger.info(f"✅ Model trained successfully. Accuracy: {accuracy*100:.2f}%")
        
        return TrainModelResponse(
            status="success",
            message=f"Model trained with {accuracy*100:.2f}% accuracy",
            metrics=metrics
        )
        
    except Exception as e:
        logger.error(f"❌ Error training model: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Model training failed: {str(e)}"
        )


@app.post("/api/v1/predict", response_model=PredictResponse)
async def predict(request: PredictRequest):
    """
    Predict success/failure for a single student
    """
    if trained_model is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No trained model available. Please train a model first."
        )
    
    try:
        # Convert features to DataFrame
        df = pd.DataFrame([request.features])
        
        # Predict
        prediction = int(trained_model.predict(df)[0])
        probability = float(trained_model.predict_proba(df)[0][1])
        
        # Determine risk level
        if probability > 0.7:
            risk_level = "HIGH"
        elif probability > 0.4:
            risk_level = "MEDIUM"
        else:
            risk_level = "LOW"
        
        return PredictResponse(
            student_id=request.features.get('ID'),
            prediction=prediction,
            probability=probability,
            risk_level=risk_level
        )
        
    except Exception as e:
        logger.error(f"❌ Error predicting: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )


@app.post("/api/v1/predict-batch", response_model=List[PredictResponse])
async def predict_batch(request: PredictBatchRequest):
    """
    Batch prediction for multiple students
    """
    if trained_model is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No trained model available. Please train a model first."
        )
    
    try:
        df = pd.DataFrame(request.data)
        
        predictions = trained_model.predict(df)
        probabilities = trained_model.predict_proba(df)[:, 1]
        
        results = []
        for i, (pred, prob) in enumerate(zip(predictions, probabilities)):
            if prob > 0.7:
                risk = "HIGH"
            elif prob > 0.4:
                risk = "MEDIUM"
            else:
                risk = "LOW"
            
            results.append(PredictResponse(
                student_id=request.data[i].get('ID'),
                prediction=int(pred),
                probability=float(prob),
                risk_level=risk
            ))
        
        return results
        
    except Exception as e:
        logger.error(f"❌ Error in batch prediction: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Batch prediction failed: {str(e)}"
        )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    logger.error(f"❌ Unhandled exception: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": f"Internal server error: {str(exc)}"}
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main_predictor:app",
        host="0.0.0.0",
        port=SERVICE_PORT,
        reload=True
    )
