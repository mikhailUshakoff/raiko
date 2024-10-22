# Use a base image with CUDA support (e.g., nvidia/cuda)
FROM nvidia/cuda:12.6.2-devel-ubuntu22.04

# Install dependencies: libssl-dev, clang, and other necessary tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    clang \
    pkg-config \
    curl \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy your project files into the container
COPY . .

# Export the TARGET environment variable
ENV TARGET=risc0

# Manually add rzup to PATH in the Dockerfile
ENV PATH="/root/.risc0/bin:${PATH}"
# Build the project dependencies
RUN make install
# Build the project
RUN make build
# Build the project with Cargo using CUDA and risc0 features
RUN cargo build -F cuda --release --features "risc0"

# Expose port 8080
EXPOSE 8080

# Build the project with Cargo using CUDA and risc0 features
CMD ["cargo", "run", "-F", "cuda", "--release", "--features", "risc0"]

