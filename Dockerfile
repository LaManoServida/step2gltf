# Build stage
FROM debian:12-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    git \
    ca-certificates \
    libfreetype6-dev \
    tcl-dev \
    tk-dev \
    libgl1-mesa-dev \
    libxmu-dev \
    libxi-dev \
    rapidjson-dev \
    libfontconfig1-dev \
    libexpat1-dev \
    libpng-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Set OCCT Memory Manager environment variables for large file support
ENV MMGT_OPT=1 \
    MMGT_CLEAR=0

# Download and build OpenCascade 7.9.1
RUN wget https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_9_1.tar.gz \
    && tar -xf V7_9_1.tar.gz \
    && cd OCCT-7_9_1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    -DUSE_RAPIDJSON=ON \
    -DBUILD_MODULE_Visualization=ON \
    -DBUILD_MODULE_Draw=OFF \
    -DBUILD_MODULE_DataExchange=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j$(nproc) install \
    && cd /build \
    && rm -rf OCCT-7_9_1 V7_9_1.tar.gz

# Copy source code
COPY . /build/step2gltf
WORKDIR /build/step2gltf

# Build step2gltf (dynamic linking)
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/opencascade.conf \
    && ldconfig \
    && make release

# Runtime stage
FROM debian:12-slim AS runtime

# Build arguments for user/group IDs (defaults to 1000:1000)
ARG USER_ID=1000
ARG GROUP_ID=1000

# Set OCCT Memory Manager environment variables for large file support at runtime
ENV MMGT_OPT=1 \
    MMGT_CLEAR=0

# Install only runtime dependencies (no build tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6 \
    tcl \
    tk \
    libgl1-mesa-glx \
    libxmu6 \
    libxi6 \
    libfontconfig1 \
    libexpat1 \
    libpng16-16 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy OpenCascade libraries and headers
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include

# Copy the built executable
COPY --from=builder /build/step2gltf/step2gltf /usr/local/bin/step2gltf

# Configure library path and make executable
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/opencascade.conf \
    && ldconfig \
    && chmod +x /usr/local/bin/step2gltf

# Create user and group with specified IDs
RUN groupadd -g ${GROUP_ID} step2gltf && useradd -u ${USER_ID} -g ${GROUP_ID} -m step2gltf

# Create workspace directory
RUN mkdir -p /workspace && chown ${USER_ID}:${GROUP_ID} /workspace

# Set working directory and user
WORKDIR /workspace
USER step2gltf

# Set the default command
ENTRYPOINT ["/usr/local/bin/step2gltf"]
CMD ["--help"]
