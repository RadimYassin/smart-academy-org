#!/bin/bash
# ============================================================================
# Smart Academy - Start AI Services Locally (Linux/Mac)
# Runs AI services without Docker to avoid long build times
# ============================================================================

echo "========================================================================"
echo " Starting AI Services Locally"
echo "========================================================================"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python is not installed. Please install Python 3.8+"
    exit 1
fi

cd AI-services

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies (only core ML libs, skip MLflow/Airflow for faster install)
echo ""
echo "Installing Python dependencies (this may take a few minutes)..."
pip install pandas numpy scikit-learn xgboost matplotlib seaborn faiss-cpu openai python-dotenv
pip install fastapi uvicorn pydantic requests

# Start each AI service in a new terminal
echo ""
echo "Starting AI Services..."

export EUREKA_SERVER_URL=http://localhost:8761/eureka

echo "[1/4] Starting PrepaData Service (Port 8001)..."
cd prepadata
export SERVICE_PORT=8001
gnome-terminal -- bash -c "source ../venv/bin/activate && python main_prepadata.py; exec bash" &
cd ..
sleep 2

echo "[2/4] Starting StudentProfiler Service (Port 8002)..."
cd profiler
export SERVICE_PORT=8002
gnome-terminal -- bash -c "source ../venv/bin/activate && python main_profiler.py; exec bash" &
cd ..
sleep 2

echo "[3/4] Starting PathPredictor Service (Port 8003)..."
cd predictor
export SERVICE_PORT=8003
gnome-terminal -- bash -c "source ../venv/bin/activate && python main_predictor.py; exec bash" &
cd ..
sleep 2

echo "[4/4] Starting RecoBuilder Service (Port 8004)..."
cd recobuilder
export SERVICE_PORT=8004
gnome-terminal -- bash -c "source ../venv/bin/activate && python main_recobuilder.py; exec bash" &
cd ..

echo ""
echo "========================================================================"
echo " AI Services Starting in Separate Terminals"
echo "========================================================================"
echo " PrepaData:         http://localhost:8001/docs"
echo " StudentProfiler:   http://localhost:8002/docs"
echo " PathPredictor:     http://localhost:8003/docs"
echo " RecoBuilder:       http://localhost:8004/docs"
echo "========================================================================"
echo ""
echo "Wait 30 seconds then check Eureka: http://localhost:8761"
echo ""
