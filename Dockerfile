# ================================================================
# STAGE 1 — Build TitanPl
# ================================================================
FROM node:20.11.1-slim AS builder

# ---- Essential Build Tools + Rust (Stable for Edition 2024) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    bash \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain stable --profile minimal \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV NODE_ENV=production
ENV RUSTFLAGS="-C target-cpu=native -C strip=symbols"

WORKDIR /app

# ---------------- Rust Dependency Cache ----------------
RUN mkdir -p server/src
COPY server/Cargo.toml server/Cargo.lock* server/
RUN echo "fn main(){}" > server/src/main.rs
WORKDIR /app/server
RUN cargo build --release
RUN rm src/main.rs
WORKDIR /app

# ---------------- Node Dependency Cache ----------------
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then \
    npm ci --omit=dev; \
    else \
    npm install --omit=dev; \
    fi

# ---------------- Install Titan CLI ----------------
RUN npm install -g @ezetgalaxy/titan@latest

# ---------------- Copy Project Files ----------------
COPY . .

# ---------------- Titan Metadata + Action Bundles ----------------
RUN node app/app.js --build && titan build

# ---------------- Extract Titan Extensions ----------------
SHELL ["/bin/bash", "-c"]
RUN mkdir -p /app/.ext && \
    find /app/node_modules -type f -name "titan.json" -print0 | \
    while IFS= read -r -d '' file; do \
    pkg_dir="$(dirname "$file")"; \
    pkg_name="$(basename "$pkg_dir")"; \
    if [[ "$pkg_name" != "." ]]; then \
    cp -r "$pkg_dir" "/app/.ext/$pkg_name"; \
    rm -rf "/app/.ext/$pkg_name/node_modules"; \
    fi; \
    done

# ---------------- Rust Final Build ----------------
RUN cd server && cargo build --release



# ================================================================
# STAGE 2 — Runtime Image (Node-Free)
# ================================================================
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# ---- Non-Root User ----
RUN useradd -m titan
USER titan

WORKDIR /app

# ---- Copy Artifacts ----
COPY --from=builder /app/server/target/release/titan-server ./titan-server
COPY --from=builder /app/server/routes.json .
COPY --from=builder /app/server/action_map.json .
COPY --from=builder /app/server/src/actions ./actions
COPY --from=builder /app/app/static ./static
COPY --from=builder /app/.ext ./.ext

# ---- Proof: Node Not Present ----
RUN which node && exit 1 || echo "NodeJS not present ✔"

# ---- Optional Healthcheck ----
HEALTHCHECK CMD curl -f http://localhost:${PORT:-5100}/ || exit 1

EXPOSE 5100

CMD ["./titan-server"]
