# llama-server on Raspberry Pi 4

Local LAN LLM server running **Granite 4.1 3B** (Q4\_K\_M) via llama.cpp, with OpenAI-compatible tool calling.

## Quick start

```bash
cp .env.example .env   # edit if needed (especially MEM_LIMIT for 4GB Pi)
docker compose up -d    # first run downloads ~2GB model + builds llama.cpp
docker compose logs -f  # watch for "llama server listening"
```

Build takes ~15–20 min on a Pi 4 (compiling llama.cpp from source). Subsequent starts are instant.

## Verify it works

```bash
# Simple completion
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Tool calling
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "What time is it in Tokyo?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_time",
        "description": "Get the current time in a timezone",
        "parameters": {
          "type": "object",
          "properties": {
            "timezone": {"type": "string", "description": "IANA timezone"}
          },
          "required": ["timezone"]
        }
      }
    }]
  }'
```

## Accessing from other machines on your LAN

Replace `localhost` with your Pi's IP:

```
http://<pi-ip>:8080/v1/chat/completions
```

The server is OpenAI API–compatible, so it works with any client that supports a custom base URL (Open WebUI, LiteLLM, Cline, etc.).

## Swapping models

Edit `MODEL_URL` and `MODEL_FILENAME` in `docker-compose.yml` or `.env`. The model volume persists, so delete the old file first if you want to reclaim space:

```bash
docker compose down
docker volume rm llama-server_models   # or just shell in and rm the file
# update MODEL_URL / MODEL_FILENAME
docker compose up -d
```

### Other models that work well on Pi 4 with tool calling

| Model | Size (Q4\_K\_M) | Notes |
|-------|----------------|-------|
| Granite 4.1 3B | ~2 GB | **Recommended.** Best tool calling at this size. |
| Qwen3-1.7B | ~1.2 GB | Faster, lighter, decent tool calling |
| Qwen3-4B | ~2.8 GB | Better quality, tight on 4GB Pi |

## 4GB Pi 4

Set `MEM_LIMIT=3g`, `CTX_SIZE=2048`, and stick with Q4\_K\_M or smaller. It'll work but be tight.

## Performance expectations

- **~3–5 tok/s** on Pi 4 (Cortex-A72) for Granite 4.1 3B Q4\_K\_M
- Tool calls add latency (JSON schema constraint decoding)
- Good enough for async/background agents, not real-time chat
- Use active cooling — sustained inference will thermal-throttle
