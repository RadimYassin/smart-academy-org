# 🚀 AI Services API - FastAPI Wrapper for Python AI/ML Services

## Overview

This FastAPI application wraps the Python AI services (PrepaData, StudentProfiler, PathPredictor, RecoBuilder) and exposes them as REST APIs that integrate with the Spring Cloud microservices ecosystem.

## Features

- ✅ **Eureka Service Discovery** - Registers with Eureka Server
- ✅ **Gateway Integration** - Routes through API Gateway
- ✅ **REST APIs** for all 4 AI services
- ✅ **Health Checks** - Eureka-compatible health endpoints
- ✅ **OpenAPI Docs** - Auto-generated at `/docs`

## Architecture

```
Gateway (8888)
    ↓
/ai/api/prepadata/*    → PrepaData (data cleaning)
/ai/api/profiler/*     → StudentProfiler (clustering)
/ai/api/predictor/*    → PathPredictor (failure prediction)
/ai/api/recommender/*  → RecoBuilder (AI recommendations)
```

## Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and set:
# - EUREKA_SERVER
# - OPENAI_API_KEY (for RecoBuilder)
# - DATABASE_URL
```

## Running

### Local Development

```bash
# Start the service
python -m app.main

# Service will be available at:
# - API: http://localhost:8083
# - Docs: http://localhost:8083/docs
# - Health: http://localhost:8083/health
```

### With Docker

```bash
# Build image
docker build -t ai-services-api .

# Run container
docker run -p 8083:8083 --env-file .env ai-services-api
```

## API Endpoints

### PrepaData
- `POST /api/prepadata/clean` - Clean and normalize data
- `GET /api/prepadata/status` - Service status

### StudentProfiler
- `POST /api/profiler/profile` - Create student clusters
- `GET /api/profiler/status` - Service status

### PathPredictor
- `POST /api/predictor/train` - Train XGBoost model
- `POST /api/predictor/predict` - Predict student failure
- `GET /api/predictor/status` - Service status

### RecoBuilder
- `POST /api/recommender/generate` - Generate AI recommendations
- `GET /api/recommender/status` - Service status

## Testing

```bash
# Test via Gateway
curl http://localhost:8888/ai/health

# Test direct
curl http://localhost:8083/health

# Access OpenAPI docs
open http://localhost:8083/docs
```

## Eureka Registration

The service automatically registers with Eureka on startup at the configured `EUREKA_SERVER` URL.

Check Eureka dashboard at http://localhost:8761 to verify registration.

## Configuration

All configuration is managed via environment variables in `.env`:

- `APP_NAME` - Service name in Eureka (default: ai-services-api)
- `APP_PORT` - Port to run on (default: 8083)
- `EUREKA_SERVER` - Eureka server URL
- `OPENAI_API_KEY` - Required for RecoBuilder
- `DATABASE_URL` - PostgreSQL connection string

## Dependencies

See `requirements.txt` for full list. Key dependencies:
- FastAPI - Web framework
- py-eureka-client - Eureka registration
- pandas, numpy - Data processing
- scikit-learn - ML algorithms
- xgboost - Prediction model
- openai - AI recommendations
- faiss-cpu - Vector search
