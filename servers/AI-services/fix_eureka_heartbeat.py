"""
Fix for all AI services - adds Eureka heartbeat functionality
Copy this snippet to each main_*.py file's lifespan function
"""

HEARTBEAT_CODE = '''
    # Start heartbeat task
    import asyncio
    from shared.eureka_client import send_heartbeat
    import socket
    
    hostname = socket.gethostname()
    instance_id = f"{hostname}:{APP_NAME}:{SERVICE_PORT}"
    heartbeat_task = None
    
    async def send_heartbeats():
        """Send periodic heartbeats to Eureka"""
        while True:
            try:
                await asyncio.sleep(30)  # Send heartbeat every 30 seconds
                send_heartbeat(APP_NAME, instance_id, EUREKA_SERVER)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Heartbeat error: {e}")
    
    heartbeat_task = asyncio.create_task(send_heartbeats())
'''

SHUTDOWN_CODE = '''
    # Shutdown
    if heartbeat_task:
        heartbeat_task.cancel()
        try:
            await heartbeat_task
        except asyncio.CancelledError:
            pass
'''

# Service configurations
SERVICES = [
    ("profiler", "studentprofiler-service", 8002),
    ("predictor", "pathpredictor-service", 8003),
    ("recobuilder", "recobuilder-service", 8004)
]

print("Add this code after 'register_with_eureka()' in each service's lifespan function:")
print("=" * 70)
print(HEARTBEAT_CODE)
print("\nReplace the shutdown section with:")
print(SHUTDOWN_CODE)
