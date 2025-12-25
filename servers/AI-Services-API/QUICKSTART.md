# 🚀 Quick Start Guide - AI Services Integration

## Step 1: Install Dependencies

```bash
cd AI-Services-API
pip install -r requirements.txt
```

## Step 2: Configure Environment

Edit `.env` file and set your OpenAI API key:
```bash
OPENAI_API_KEY=sk-your-actual-api-key-here
```

## Step 3: Start All Services

### Terminal 1: Eureka Server
```bash
cd Eureka-Server
mvn spring-boot:run
```

Wait for: `Application started on port 8761`

### Terminal 2: Gateway
```bash
cd GateWay
mvn spring-boot:run
```

Wait for: `Application started on port 8888`

### Terminal 3: User-Management  
```bash
cd User-Management
mvn spring-boot:run
```

Wait for: `Application started on port 8082`

### Terminal 4: LMSConnector
```bash
cd lmsconnector
npm install
npm run start:dev
```

Wait for: `Application is running on: http://localhost:3000`

### Terminal 5: AI-Services-API
```bash
cd AI-Services-API
python -m app.main
```

Wait for: `✅ ai-services-api registered with Eureka successfully!`

## Step 4: Verify Registration

Open http://localhost:8761 in browser

You should see:
- GATEWAY-SERVICE
- USER-MANAGEMENT-SERVICE
- AI-SERVICES-API ← New!

## Step 5: Test the Integration

```bash
# Test health via Gateway
curl http://localhost:8888/ai/health

# Test PrepaData status
curl http://localhost:8888/ai/api/prepadata/status

# Test PathPredictor status
curl http://localhost:8888/ai/api/predictor/status

# Access API docs
open http://localhost:8083/docs
```

## Step 6: Use the Services

Access Swagger UI at http://localhost:8083/docs to:
- Upload data to PrepaData
- Create student profiles
- Train prediction model
- Generate recommendations

All requests through Gateway: `http://localhost:8888/ai/...`

## Troubleshooting

**Eureka registration fails:**
- Check Eureka is running on port 8761
- Verify EUREKA_SERVER in .env

**Gateway can't route:**
- Rebuild Gateway: `mvn clean install`
- Restart Gateway service

**Import errors in Python:**
- Make sure you're in the project root
- Check that ../src directory exists with pipeline.py and recobuilder.py
