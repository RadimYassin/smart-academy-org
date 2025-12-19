"""
Eureka Service Registration for Chatbot-edu
"""
import py_eureka_client.eureka_client as eureka_client
import logging
import os

logger = logging.getLogger(__name__)

def register_with_eureka(
    app_name: str = "chatbot-edu-service",
    port: int = 8005,
    eureka_server: str = "http://localhost:8761/eureka"
):
    """
    Register Chatbot-edu service with Eureka Server
    
    Args:
        app_name: Service name in Eureka
        port: Port where service is running
        eureka_server: Eureka server URL
    """
    try:
        # Determine host based on environment
        instance_host = os.getenv("EUREKA_INSTANCE_HOSTNAME", "localhost")
        
        logger.info(f"🔌 Registering with Eureka: {eureka_server}")
        logger.info(f"📱 Service: {app_name} on {instance_host}:{port}")
        
        eureka_client.init(
            eureka_server=eureka_server,
            app_name=app_name,
            instance_port=port,
            instance_host=instance_host,
            renewal_interval_in_secs=30,
            duration_in_secs=90
        )
        
        logger.info(f"✅ Successfully registered with Eureka: {app_name}")
        
    except Exception as e:
        logger.error(f"❌ Failed to register with Eureka: {e}")
        logger.warning("⚠️  Service will run without Eureka registration")
        # Don't raise - allow service to run even if Eureka is unavailable
