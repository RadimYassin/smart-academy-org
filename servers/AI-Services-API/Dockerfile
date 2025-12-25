FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Copy data and outputs directories (create if they don't exist)
RUN mkdir -p /app/data/raw /app/data/processed /app/data/resources /app/outputs/models /app/outputs/figures

# Copy src folder (AI service implementations)
COPY ../src/ /app/src/

# Expose port
EXPOSE 8083

# Run the application
CMD ["python", "-m", "app.main"]
