# Chatbot-edu Integration Status

## ✅ Successfully Integrated

The chatbot-edu microservice is fully integrated into the Smart Academy microservices architecture.

---

## Integration Points

### 1. Docker Compose
- **Configuration**: Defined in [`docker-compose.yml`](file:///d:/smart-academy-org/servers/docker-compose.yml)
- **Container Name**: `chatbot-edu-service`
- **Port**: 8005
- **Image**: Python 3.11-slim

### 2. Service Discovery
- **Eureka Server**: Registers as `CHATBOT-EDU-SERVICE`
- **Registration**: Automatic on startup via [`eureka_reg.py`](file:///d:/smart-academy-org/servers/Chatbot-edu/auth/eureka_reg.py)
- **Health Check**: `/health` endpoint

### 3. API Gateway
- **Route**: `/chatbot/**`
- **Gateway Access**: `http://localhost:8888/chatbot`
- **Direct Access**: `http://localhost:8005`

### 4. Storage
- **MinIO**: Object storage for course materials
- **Bucket**: `course-materials`
- **Endpoint**: `minio:9000`
- **Console**: http://localhost:9001

### 5. Authentication
- **JWT**: Supports JWT token authentication
- **Secret**: Shared with other microservices
- **Header**: `Authorization: Bearer <token>`

---

## Access Points

| Access Method | URL | Purpose |
|---------------|-----|---------|
| **Direct HTTP** | http://localhost:8005 | Development/debugging |
| **Via Gateway** | http://localhost:8888/chatbot | Production route |
| **Swagger UI (Direct)** | http://localhost:8005/docs | API documentation |
| **Swagger UI (Gateway)** | http://localhost:8888/chatbot/docs | API documentation |
| **Health Check** | http://localhost:8005/health | Service health status |

---

## Environment Configuration

All configuration is managed via environment variables in `docker-compose.yml`:

### LLM Provider
- `LLM_PROVIDER`: openai, ollama, or gemini
- `OPENAI_API_KEY`: Your OpenAI API key
- `OPENAI_MODEL`: Model name (default: gpt-4o-mini)
- `OPENAI_TEMPERATURE`: 0-1 (default: 0.7)

### Service Discovery
- `EUREKA_SERVER_URL`: http://eureka-server:8761/eureka
- `EUREKA_INSTANCE_HOSTNAME`: chatbot-edu-service
- `SERVICE_PORT`: 8005

### Authentication
- `JWT_SECRET`: Shared secret with other services

### Storage
- `MINIO_ENDPOINT`: minio:9000
- `MINIO_ACCESS_KEY`: minioadmin
- `MINIO_SECRET_KEY`: minioadmin
- `MINIO_BUCKET_NAME`: course-materials

### FAISS Configuration
- `FAISS_INDEX_PATH`: /app/faiss_index
- `CHUNK_SIZE`: 1000 tokens
- `CHUNK_OVERLAP`: 200 tokens
- `RETRIEVAL_TOP_K`: 4 documents

---

## API Endpoints

### Chat Endpoint
**POST** `/chat/ask`

Ask questions about course materials using RAG (Retrieval Augmented Generation).

```bash
curl -X POST http://localhost:8888/chatbot/chat/ask \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "question": "What are the main topics in the course?"
  }'
```

### Admin Endpoint
**POST** `/admin/ingest`

Ingest PDF documents from MinIO to create FAISS vector index.

```bash
curl -X POST http://localhost:8888/chatbot/admin/ingest \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Health Check
**GET** `/health`

Check service health and configuration status.

```bash
curl http://localhost:8888/chatbot/health
```

---

## Usage Workflow

### Initial Setup

1. **Start All Services**
   ```bash
   cd d:\smart-academy-org\servers
   docker-compose up -d
   ```

2. **Verify Eureka Registration**
   - Visit: http://localhost:8761
   - Confirm: `CHATBOT-EDU-SERVICE` appears in registered instances

3. **Upload Course Materials to MinIO**
   - Visit: http://localhost:9001
   - Login: minioadmin / minioadmin
   - Upload PDF files to `course-materials` bucket

4. **Ingest Documents**
   ```bash
   # Get JWT token first by logging in
   TOKEN=$(curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"admin@example.com","password":"admin123"}' \
     | jq -r '.token')
   
   # Trigger ingestion
   curl -X POST http://localhost:8888/chatbot/admin/ingest \
     -H "Authorization: Bearer $TOKEN"
   ```

5. **Ask Questions**
   ```bash
   curl -X POST http://localhost:8888/chatbot/chat/ask \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $TOKEN" \
     -d '{"question": "Explain the main concepts"}'
   ```

---

## Technical Stack

- **Framework**: FastAPI 0.109.0
- **Server**: Uvicorn 0.27.0
- **AI Orchestration**: LangChain 0.2.11
- **Vector Store**: FAISS (CPU version)
- **Embeddings**: Sentence Transformers (all-MiniLM-L6-v2)
- **LLM**: OpenAI GPT-4o-mini (configurable)
- **PDF Processing**: PyPDF 3.17.4
- **Object Storage**: MinIO Client 7.2.3
- **Service Discovery**: py-eureka-client 0.10.3
- **Authentication**: PyJWT 2.8.0

---

## Persistent Volumes

| Volume Name | Mount Point | Purpose |
|-------------|-------------|---------|
| `chatbot-faiss` | `/app/faiss_index` | Vector index storage |
| `chatbot-courses` | `/app/Cours` | Local course cache |
| `chatbot-temp` | `/app/temp_pdfs` | Temporary PDF processing |

**Important**: If you remove these volumes, you'll need to re-ingest documents.

---

## Dependencies

The service depends on:

1. **Eureka Server** - Service discovery
2. **MinIO** - Document storage
3. **LLM Provider** - OpenAI API (or local Ollama/Gemini)

The service is **independent** of:
- PostgreSQL databases
- User Management service
- Course Management service
- LMS Connector service

---

## Known Limitations

1. **LLM API Key Required**: Service won't function without a valid LLM provider configured
2. **No Database**: Stateless service using FAISS for vector storage only
3. **FAISS Index Ephemeral**: Index must be rebuilt if container recreated without volume persistence
4. **No Unit Tests**: Service currently lacks automated tests
5. **JWT Not Enforced**: Authentication middleware exists but may not be enforced on all endpoints

---

## Troubleshooting

### Service Not Appearing in Eureka

**Check logs**:
```bash
docker-compose logs chatbot-edu
```

**Look for**:
```
✅ Successfully registered with Eureka: chatbot-edu-service
```

**Solution**: Wait 30-60 seconds for registration to complete.

### Health Check Returns "degraded"

**Cause**: FAISS index not yet created

**Response Example**:
```json
{
  "status": "degraded",
  "faiss_index_exists": false,
  "llm_provider": "openai",
  "model": "gpt-4o-mini"
}
```

**Solution**: Run document ingestion first.

### Ingestion Fails

**Check**:
1. MinIO is accessible
2. Bucket `course-materials` exists
3. PDF files are in the bucket

**Debug**:
```bash
docker-compose logs chatbot-edu | grep -i error
```

### Questions Return Empty Responses

**Causes**:
1. FAISS index is empty
2. LLM API key invalid or quota exceeded
3. Question not related to indexed content

**Solution**: Check logs and verify ingestion completed successfully.

---

## Performance Considerations

- **Cold Start**: First request may take 5-10 seconds
- **Embedding Generation**: ~1-2 seconds per query
- **LLM Response**: 2-5 seconds depending on provider
- **Document Ingestion**: ~30-60 seconds for 10-20 PDFs

---

## Security Notes

> [!WARNING]
> **Production Security Requirements**:
> - Generate unique JWT secret
> - Enable JWT enforcement on all endpoints
> - Use HTTPS for all communication
> - Secure MinIO credentials
> - Store LLM API keys in secrets manager
> - Implement rate limiting
> - Add input validation and sanitization

---

## Monitoring

### Health Checks

The service implements Docker health checks:
```yaml
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8005/health || exit 1
```

### Logs

View real-time logs:
```bash
docker-compose logs -f chatbot-edu
```

### Resource Usage

Monitor containers:
```bash
docker stats chatbot-edu-service
```

---

## Future Enhancements

- [ ] Add comprehensive unit tests
- [ ] Implement JWT enforcement on all endpoints
- [ ] Add caching layer for frequent queries
- [ ] Support conversation history
- [ ] Add metrics and monitoring (Prometheus)
- [ ] Implement multi-language support
- [ ] Add support for more document formats (DOCX, TXT, etc.)
- [ ] Improve error handling and retry logic
- [ ] Add rate limiting per user
- [ ] Implement streaming responses

---

**Integration Status**: ✅ Complete and Operational
**Last Updated**: 2025-12-18
**Version**: 1.0.0
