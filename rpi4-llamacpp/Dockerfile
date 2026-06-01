# ---- Build stage ----
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git ca-certificates libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

ARG LLAMA_CPP_TAG=b8970
RUN git clone --depth 1 --branch ${LLAMA_CPP_TAG} \
    https://github.com/ggml-org/llama.cpp /build/llama.cpp

WORKDIR /build/llama.cpp

RUN cmake -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DGGML_CUDA=OFF \
    -DGGML_VULKAN=OFF \
    -DGGML_NATIVE=OFF \
    -DLLAMA_CURL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release -j2 \
       --target llama-server llama-cli

# ---- Runtime stage ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libcurl4 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/llama.cpp/build/bin/llama-server /usr/local/bin/
COPY --from=builder /build/llama.cpp/build/bin/llama-cli     /usr/local/bin/

# Copy bundled Jinja chat template overrides (if present at this version)
COPY --from=builder /build/llama.cpp/models/ /opt/llama/models/

RUN mkdir -p /models

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]