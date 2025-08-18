FROM debian:12-slim

# Install build and runtime dependencies
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
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

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

# Build step2gltf (dynamic linking for simplicity)
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/opencascade.conf \
    && ldconfig \
    && make release

# Create working directory for input/output files
WORKDIR /workspace

# Copy the binary to a standard location
RUN cp /build/step2gltf/step2gltf /usr/local/bin/step2gltf \
    && chmod +x /usr/local/bin/step2gltf

# Default command
ENTRYPOINT ["/usr/local/bin/step2gltf"]
CMD ["--help"]
