# Dockerfile
FROM rust:latest AS builder

# Install dependencies
RUN apt-get update && \
    apt-get install -y cmake clang git curl libssl-dev pkg-config  && \
    rm -rf /var/lib/apt/lists/*

# Build SUI from source
RUN cargo install --debug --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui

# Runtime stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libssl-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /sui/target/release/sui /usr/local/bin/

WORKDIR /app