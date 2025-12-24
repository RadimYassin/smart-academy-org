FROM python:3.9-slim

WORKDIR /app

COPY ../requirements.txt /app/
COPY ../requirements-api.txt /app/

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r requirements-api.txt

COPY ../src /app/src
COPY ../shared /app/shared
COPY predictor/main_predictor.py /app/

RUN mkdir -p /app/data /app/outputs /app/models

EXPOSE 8003

CMD ["uvicorn", "main_predictor:app", "--host", "0.0.0.0", "--port", "8003"]
