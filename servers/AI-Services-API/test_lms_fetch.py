# Quick test script to debug LMS data fetch
import httpx
import asyncio

async def test_lms_fetch():
    url = "http://localhost:8888/lmsconnector/ingestion/ai-data"
    
    # You need to replace this with your actual JWT token
    token = input("Paste your JWT token: ")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, headers=headers, timeout=30.0)
            print(f"Status: {response.status_code}")
            print(f"Response type: {type(response.json())}")
            data = response.json()
            print(f"Data: {data}")
            print(f"Length: {len(data) if isinstance(data, list) else 'Not a list'}")
            if isinstance(data, list) and len(data) > 0:
                print(f"First item: {data[0]}")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_lms_fetch())
