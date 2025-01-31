# Dockerfile
FROM rust:latest AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    clang \
    git \
    curl \
    libssl-dev \
    pkg-config

# Build SUI from source
RUN git clone https://github.com/MystenLabs/sui.git && \
    cd sui && \
    git checkout devnet && \
    cargo build --release --bin sui

# Runtime image
FROM rust:slim
COPY --from=builder /sui/target/release/sui /usr/local/bin/

# Install Bun for commitlint
RUN curl -fsSL https://bun.sh/install | bash && \
    apt-get update && apt-get install -y git

WORKDIR /app
COPY . .

# Default command
CMD ["sui", "move", "test"]