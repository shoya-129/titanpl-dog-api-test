# ================================================================
# STAGE 1 — Build TitanPl 
# ================================================================
FROM node:20-slim AS builder

# ---- Essential Build Tools + Minimal Rust ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.84.0 --profile minimal \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV NODE_ENV=production
ENV RUSTFLAGS="-C target-cpu=native -C strip=symbols"

WORKDIR /app

# ---------------- Rust Cache ----------------
RUN mkdir -p server/src
COPY server/Cargo.toml server/Cargo.lock* server/
RUN echo "fn main(){}" > server/src/main.rs
WORKDIR /app/server
RUN cargo build --release
RUN rm src/main.rs
WORKDIR /app

# ---------------- Node Cache ----------------
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev && npm install -g @ezetgalaxy/titan@latest

# ---------------- Copy App ----------------
COPY . .

# ---------------- Titan Build & Action Bundling ----------------
RUN node app/app.js --build && titan build

# ---------------- Rust Final Build ----------------
RUN cd server && cargo build --release

# ================================================================
# STAGE 2 — Runtime Image
# ================================================================
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m titan
WORKDIR /app
USER titan

# ---- Copy Artifacts ----
COPY --from=builder /app/server/target/release/titan-server ./titan-server
COPY --from=builder /app/server/routes.json .
COPY --from=builder /app/server/action_map.json .
COPY --from=builder /app/server/src/actions ./src/actions
COPY --from=builder /app/app/static ./static
COPY --from=builder /app/.ext ./.ext

EXPOSE 5100

CMD ["./titan-server"]