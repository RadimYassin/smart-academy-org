FROM python:3.9-slim

WORKDIR /app

# Copy requirements
COPY ../requirements.txt /app/
COPY ../requirements-api.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r requirements-api.txt

# Copy source code
COPY ../src /app/src
COPY ../shared /app/shared
COPY prepadata/main_prepadata.py /app/

# Create necessary directories
RUN mkdir -p /app/data /app/outputs

# Expose port
EXPOSE 8001

# Run the service
CMD ["uvicorn", "main_prepadata:app", "--host", "0.0.0.0", "--port", "8001"]
