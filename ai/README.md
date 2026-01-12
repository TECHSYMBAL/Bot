# AI Chat Backend API - Railway Deployment

FastAPI backend for AI chat using Ollama. This is the backend-only branch for Railway deployment.

**Ollama is installed directly in the Railway container** - no external setup needed!

## Setup

### Deploy to Railway

1. Connect your GitHub repo to Railway
2. Railway will auto-detect the Dockerfile and build
3. Optional environment variables:
   - `OLLAMA_MODEL`: Model name to use (default: "llama3.2:3b" - multilingual model optimized for 8GB RAM)
   - `API_KEY`: Required - API key for authentication (generate using `python backend/generate_api_key.py`)
   - `PORT`: Railway sets this automatically

**Note:** 
- Default model is `llama3.2:3b` (~2GB) - free and open-source multilingual model (Apache 2.0 license)
- Optimized for 8GB RAM / 8 vCPU Railway services
- Supports 100+ languages with strong multilingual capabilities
- The first deployment will take longer as it downloads and installs Ollama and pulls the AI model (~2-3GB download)
- Alternative models you can use:
  - `qwen2.5:3b` - Strong multilingual support, especially for Asian languages
  - `mistral:7b` - Higher quality but requires more RAM (may be tight on 8GB)
  - `phi3:mini` - Efficient multilingual model

### Local Development

```bash
cd backend
pip install -r requirements.txt
python main.py
```

The API will run on http://localhost:8000

## API Endpoints

- `GET /` - Health check
- `POST /api/chat` - Send message, get AI response
  ```json
  {
    "message": "Hello, how are you?"
  }
  ```

