"""
RecoBuilder Router - AI-powered recommendation generation endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Dict, Any
import pandas as pd
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../src'))
from recobuilder import RecoBuilder
from app.config import settings
from app.auth.jwt_middleware import get_current_user

router = APIRouter()


class RecommendationRequest(BaseModel):
    student_ids: List[int]
    resources_path: str = None


class RecommendationResponse(BaseModel):
    status: str
    message: str
    total_recommendations: int
    output_path: str


@router.post("/generate", response_model=RecommendationResponse)
async def generate_recommendations(
    request: RecommendationRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Generate personalized recommendations for students
    
    - **student_ids**: List of student IDs to generate recommendations for
    - **resources_path**: Optional path to educational resources JSON file
    """
    try:
        # Check if OpenAI API key is configured
        if not settings.OPENAI_API_KEY or settings.OPENAI_API_KEY == "":
            raise HTTPException(
                status_code=503,
                detail="OpenAI API key not configured. Please set OPENAI_API_KEY in .env file."
            )
        
        # Use provided resources path or default
        resources_path = request.resources_path or settings.DATA_PATH_RAW + "/resources/educational_resources.json"
        
        # Check if student profiles exist
        profiles_path = settings.DATA_PATH_PROFILES
        if not os.path.exists(profiles_path):
            raise HTTPException(
                status_code=404,
                detail="Student profiles not found. Please run StudentProfiler first."
            )
        
        # Load student profiles
        profiles_df = pd.read_csv(profiles_path)
        
        # Filter for requested students
        student_profiles = profiles_df[profiles_df['ID'].isin(request.student_ids)]
        
        if student_profiles.empty:
            raise HTTPException(
                status_code=404,
                detail=f"No profiles found for student IDs: {request.student_ids}"
            )
        
        print(f"📊 Generating recommendations for {len(student_profiles)} students")
        
        # Generate recommendations
        reco = RecoBuilder(student_profiles, resources_path)
        recommendations_list = reco.generate_recommendations()
        
        # Convert to DataFrame
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


@router.post("/recommend-at-risk-from-lms")
async def recommend_at_risk_from_lms(
    authorization: str = Header(None),
    current_user: dict = Depends(get_current_user)
):
    """
    Combined endpoint: Predict risk and generate recommendations for at-risk students
    
    NO BODY REQUIRED - Automatically:
    1. Fetches student data from LMS
    2. Predicts risk for each student  
    3. Generates recommendations for Medium/High risk students
    """
    try:
        import httpx
        from collections import defaultdict
        import pickle
        
        # Check if model exists
        model_path = "../outputs/models/xgboost_model.pkl"
        if not os.path.exists(model_path):
            raise HTTPException(status_code=404, detail="Model not found")
        
        # Fetch course records from LMS
        lms_url = f"{settings.GATEWAY_URL}/lmsconnector/ingestion/ai-data"
        
        print(f"📡 Fetching course records from LMS...")
        
        async with httpx.AsyncClient() as client:
            headers = {}
            if authorization:
                headers["Authorization"] = authorization
            
            response = await client.get(lms_url, headers=headers, timeout=30.0)
            response.raise_for_status()
            course_records = response.json()
        
        if not course_records:
            raise HTTPException(status_code=404, detail="No course data found")
        
        print(f"✅ Retrieved {len(course_records)} course records")
        
        # Aggregate by student
        student_data = defaultdict(lambda: {
            'practical_scores': [],
            'theoretical_scores': [],
            'total_scores': [],
            'studentName': '',
            'studentId': 0
        })
        
        for record in course_records:
            sid = record.get('studentId', record.get('id', 0))
            student_data[sid]['studentId'] = sid
            student_data[sid]['studentName'] = record.get('studentName', 'Unknown')
            student_data[sid]['practical_scores'].append(record.get('practical', 0))
            student_data[sid]['theoretical_scores'].append(record.get('theoretical', 0))
            student_data[sid]['total_scores'].append(record.get('total', 0))
        
        # Create features
        students_df_list = []
        student_ids_list = []
        student_names = {}
        
        for student_id, data in student_data.items():
            avg_practical = sum(data['practical_scores']) / len(data['practical_scores']) if data['practical_scores'] else 0
            avg_theoretical = sum(data['theoretical_scores']) / len(data['theoretical_scores']) if data['theoretical_scores'] else 0
            avg_total = sum(data['total_scores']) / len(data['total_scores']) if data['total_scores'] else 0
            
            students_df_list.append({
                'Subject_Encoded': 0,
                'Semester': 1,
                'Practical': avg_practical,
                'Theoretical': avg_theoretical,
                'Total': avg_total,
                'MajorYear': 1,
                'Major_Encoded': 0
            })
            student_ids_list.append(student_id)
            student_names[student_id] = data['studentName']
        
        # Load model and predict
        with open(model_path, "rb") as f:
            model = pickle.load(f)
        
        students_df = pd.DataFrame(students_df_list)
        predictions_array = model.predict(students_df)
        probabilities_array = model.predict_proba(students_df)
        
        # Build results
        at_risk_students = []
        all_predictions = []
        
        for student_id, prediction, probabilities in zip(student_ids_list, predictions_array, probabilities_array):
            prob_fail = float(probabilities[1])
            
            if prob_fail < 0.3:
                risk_level = "Low"
            elif prob_fail < 0.7:
                risk_level = "Medium"
            else:
                risk_level = "High"
            
            pred_data = {
                "student_id": int(student_id),
                "student_name": student_names[student_id],
                "prediction": "Fail" if prediction == 1 else "Success",
                "probability_fail": round(prob_fail, 4),
                "risk_level": risk_level
            }
            
            all_predictions.append(pred_data)
            
            if risk_level in ["Medium", "High"]:
                at_risk_students.append(pred_data)
        
        print(f"🎯 Found {len(at_risk_students)} at-risk students")
        
        # Generate AI-powered recommendations using OpenAI
        if not at_risk_students:
            return {
                "status": "success",
                "message": "All students performing well!",
                "total_students": len(all_predictions),
                "at_risk_count": 0,
                "predictions": all_predictions,
                "recommendations": []
            }
        
        # Check OpenAI key
        if not settings.OPENAI_API_KEY:
            # Fallback to rule-based if no OpenAI key
            recommendations = []
            for student in at_risk_students:
                risk = student["risk_level"]
                recs = [
                    "🚨 URGENT: Schedule tutoring" if risk == "High" else "⚠️ Monitor progress",
                    "📚 Additional support recommended",
                    "👥 Peer mentoring suggested"
                ]
                recommendations.append({
                    "student_id": student["student_id"],
                    "student_name": student["student_name"],
                    "risk_level": risk,
                    "probability_fail": student["probability_fail"],
                    "recommendations": recs
                })
        else:
            # Use OpenAI for personalized recommendations
            from openai import OpenAI
            client = OpenAI(api_key=settings.OPENAI_API_KEY)
            
            recommendations = []
            
            for student in at_risk_students:
                try:
                    risk = student["risk_level"]
                    prob = student["probability_fail"]
                    name = student["student_name"]
                    
                    # Create personalized prompt
                    prompt = f"""You are an educational advisor. A student named {name} has been identified as {risk} risk with {prob*100:.1f}% probability of failing.

Generate 5 specific, actionable recommendations to help this student succeed. Focus on:
- Immediate interventions needed
- Study strategies
- Resource suggestions
- Support systems
- Progress monitoring

Format: Return only a JSON array of 5 recommendation strings."""

                    # Call OpenAI API
                    response = client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=[
                            {"role": "system", "content": "You are an expert educational advisor providing personalized student support recommendations."},
                            {"role": "user", "content": prompt}
                        ],
                        temperature=0.7,
                        max_tokens=500
                    )
                    
                    # Parse recommendations
                    ai_response = response.choices[0].message.content
                    import json
                    try:
                        recs = json.loads(ai_response)
                    except:
                        # If JSON parsing fails, split by newlines
                        recs = [line.strip() for line in ai_response.split('\n') if line.strip() and not line.strip().startswith('[') and not line.strip().startswith(']')][:5]
                    
                    recommendations.append({
                        "student_id": student["student_id"],
                        "student_name": name,
                        "risk_level": risk,
                        "probability_fail": prob,
                        "recommendations": recs,
                        "ai_generated": True
                    })
                    
                    print(f"  ✅ Generated AI recommendations for {name}")
                    
                except Exception as e:
                    print(f"  ⚠️ OpenAI error for student {student['student_id']}: {str(e)}")
                    # Fallback to rule-based for this student
                    recs = [
                        f"🚨 {risk} risk - immediate intervention needed",
                        "📚 Schedule tutoring sessions",
                        "👥 Connect with peer mentor",
                        "📊 Weekly progress monitoring",
                        "💬 Regular check-ins recommended"
                    ]
                    recommendations.append({
                        "student_id": student["student_id"],
                        "student_name": student["student_name"],
                        "risk_level": risk,
                        "probability_fail": student["probability_fail"],
                        "recommendations": recs,
                        "ai_generated": False
                    })
        
        print(f"✅ Generated recommendations for {len(recommendations)} at-risk students")
        
        return {
            "status": "success",
            "message": f"Analyzed {len(all_predictions)} students",
            "total_students": len(all_predictions),
            "at_risk_count": len(at_risk_students),
            "high_risk_count": len([s for s in at_risk_students if s["risk_level"] == "High"]),
            "medium_risk_count": len([s for s in at_risk_students if s["risk_level"] == "Medium"]),
            "predictions": all_predictions,
            "recommendations": recommendations
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def get_recommender_status():
    """Get RecoBuilder service status"""
    
    return {
        "service": "RecoBuilder",
        "status": "UP",
        "description": "AI-powered recommendation service",
        "technologies": ["OpenAI GPT-4", "FAISS", "Rule-based"],
        "capabilities": [
            "Personalized learning recommendations",
            "At-risk student intervention",
            "Study plan generation"
        ]
    }
