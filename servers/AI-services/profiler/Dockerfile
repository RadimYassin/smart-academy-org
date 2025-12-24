FROM python:3.9-slim

WORKDIR /app

COPY ../requirements.txt /app/
COPY ../requirements-api.txt /app/

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r requirements-api.txt

COPY ../src /app/src
COPY ../shared /app/shared
COPY profiler/main_profiler.py /app/

RUN mkdir -p /app/data /app/outputs

EXPOSE 8002

CMD ["uvicorn", "main_profiler:app", "--host", "0.0.0.0", "--port", "8002"]
