#!/bin/bash
echo "========================================================"
echo "Starting Smart Academy Microservices Architecture"
echo "========================================================"

# Function to start a service in the background
start_service() {
    local service_name=$1
    local service_dir=$2
    local port=$3
    
    echo "Starting $service_name (Port $port)..."
    cd "$service_dir" && mvn spring-boot:run > "$service_name.log" 2>&1 &
    echo "Started $service_name with PID $!"
    cd - > /dev/null
}

# Start Eureka Server
echo "1. Starting Eureka Server (Port 8761)..."
cd Eureka-Server && mvn spring-boot:run > eureka.log 2>&1 &
echo "Started Eureka Server with PID $!"
cd - > /dev/null
sleep 15

# Start Core Services
echo "2. Starting Core Services..."
cd User-Management && mvn spring-boot:run > user-management.log 2>&1 &
echo "Started User Management (8082) with PID $!"
cd - > /dev/null

cd Cour-Management && mvn spring-boot:run > course-management.log 2>&1 &
echo "Started Course Management (8081) with PID $!"
cd - > /dev/null
sleep 10

# Start Gateway Service
echo "3. Starting Gateway Service (Port 8888)..."
cd GateWay && mvn spring-boot:run > gateway.log 2>&1 &
echo "Started Gateway Service with PID $!"
cd - > /dev/null

# Start Python AI Services
echo "4. Starting Python AI Services..."

# Unset SSL variables to avoid certificate issues
unset SSL_CERT_FILE
unset REQUESTS_CA_BUNDLE
unset CURL_CA_BUNDLE

# Start each Python service
for service in PrepaData StudentProfiler PathPredictor RecoBuilder; do
    echo "Starting $service..."
    (cd "$service" && \
     pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt > /dev/null 2>&1 && \
     python main.py > "../$service.log" 2>&1 &)
    echo "Started $service with PID $!"
done

echo "========================================================"
echo "All services are starting up!"
echo "Monitor the log files for each service."
echo "========================================================"
echo "Access Points:"
echo "- Eureka Dashboard: http://localhost:8761"
echo "- Gateway: http://localhost:8888"
echo "========================================================"
echo ""
echo "Log files created in servers directory:"
echo "- eureka.log"
echo "- user-management.log"
echo "- course-management.log"
echo "- gateway.log"
echo "- PrepaData.log"
echo "- StudentProfiler.log"
echo "- PathPredictor.log"
echo "- RecoBuilder.log"
echo ""
echo "To stop all services, run: pkill -f 'spring-boot:run|python main.py'"
