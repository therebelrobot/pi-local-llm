#!/bin/sh
set -e

MODEL_DIR="/models"
MODEL_FILE="${MODEL_DIR}/${MODEL_FILENAME}"

# Download model if not already present
if [ ! -f "${MODEL_FILE}" ]; then
  echo "==> Model not found at ${MODEL_FILE}"
  echo "==> Downloading from ${MODEL_URL} ..."
  curl -L --progress-bar -o "${MODEL_FILE}.tmp" "${MODEL_URL}"
  mv "${MODEL_FILE}.tmp" "${MODEL_FILE}"
  echo "==> Download complete."
else
  echo "==> Model already present at ${MODEL_FILE}"
fi

echo "==> Starting llama-server on 0.0.0.0:${PORT:-8080}"

exec llama-server \
  --model "${MODEL_FILE}" \
  --host 0.0.0.0 \
  --port "${PORT:-8080}" \
  --jinja \
  --ctx-size "${CTX_SIZE:-4096}" \
  --threads "${THREADS:-4}" \
  --cache-type-k "${KV_CACHE_K:-f16}" \
  --cache-type-v "${KV_CACHE_V:-f16}" \
  $EXTRA_ARGS