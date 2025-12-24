"""
Shared Eureka Client for AI Services
Based on Chatbot-edu implementation
"""

import os
import logging
import requests
import socket
from typing import Optional

logger = logging.getLogger(__name__)


def get_local_ip():
    """Get local IP address"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def register_with_eureka(
    app_name: str,
    port: int,
    eureka_server: str,
    hostname: Optional[str] = None
):
    """
    Register service with Eureka Server
    
    Args:
        app_name: Application name (e.g., "prepadata-service")
        port: Service port
        eureka_server: Eureka server URL (e.g., "http://eureka-server:8761/eureka")
        hostname: Optional hostname override
    """
    try:
        # Disable SSL warnings for development
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        
        ip_address = get_local_ip()
        hostname = hostname or socket.gethostname()
        
        instance_id = f"{hostname}:{app_name}:{port}"
        
        registration_data = {
            "instance": {
                "instanceId": instance_id,
                "hostName": hostname,
                "app": app_name.upper(),
                "ipAddr": ip_address,
                "status": "UP",
                "overriddenstatus": "UNKNOWN",
                "port": {"$": port, "@enabled": "true"},
                "securePort": {"$": 443, "@enabled": "false"},
                "countryId": 1,
                "dataCenterInfo": {
                    "@class": "com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo",
                    "name": "MyOwn"
                },
                "leaseInfo": {
                    "renewalIntervalInSecs": 30,
                    "durationInSecs": 90,
                    "registrationTimestamp": 0,
                    "lastRenewalTimestamp": 0,
                    "evictionTimestamp": 0,
                    "serviceUpTimestamp": 0
                },
                "metadata": {
                    "management.port": str(port),
                },
                "homePageUrl": f"http://{hostname}:{port}/",
                "statusPageUrl": f"http://{hostname}:{port}/health",
                "healthCheckUrl": f"http://{hostname}:{port}/health",
                "vipAddress": app_name,
                "secureVipAddress": app_name,
                "isCoordinatingDiscoveryServer": "false",
                "lastUpdatedTimestamp": "0",
                "lastDirtyTimestamp": "0",
            }
        }
        
        # Register with Eureka
        # Remove trailing slash from eureka_server if present
        eureka_base = eureka_server.rstrip('/')
        eureka_url = f"{eureka_base}/apps/{app_name.upper()}"
        
        response = requests.post(
            eureka_url,
            json=registration_data,
            headers={"Content-Type": "application/json"},
            verify=False,
            timeout=10
        )
        
        if response.status_code in [200, 204]:
            logger.info(f"✅ Successfully registered {app_name} with Eureka at {eureka_server}")
            logger.info(f"   Instance ID: {instance_id}")
            logger.info(f"   IP Address: {ip_address}")
            logger.info(f"   Port: {port}")
        else:
            logger.warning(f"⚠️  Eureka registration returned status {response.status_code}")
            logger.warning(f"   Response: {response.text}")
            
    except Exception as e:
        logger.error(f"❌ Failed to register with Eureka: {str(e)}")
        logger.error(f"   Eureka Server: {eureka_server}")
        logger.error(f"   Service will continue without service discovery")


def send_heartbeat(app_name: str, instance_id: str, eureka_server: str):
    """
    Send heartbeat to Eureka
    
    Args:
        app_name: Application name
        instance_id: Instance ID
        eureka_server: Eureka server URL
    """
    try:
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        
        heartbeat_url = f"{eureka_server}/apps/{app_name.upper()}/{instance_id}"
        
        response = requests.put(
            heartbeat_url,
            verify=False,
            timeout=5
        )
        
        if response.status_code == 200:
            logger.debug(f"💓 Heartbeat sent for {app_name}")
        else:
            logger.warning(f"⚠️  Heartbeat failed: {response.status_code}")
            
    except Exception as e:
        logger.error(f"❌ Heartbeat error: {str(e)}")
