# step2gltf

Fork of [@s1mb1o/step2gltf](https://github.com/s1mb1o/step2gltf) - Program to convert ISO 10303 STEP files (AP203 and AP 214) to GLTF 2.0 using OpenCascade.

For complete documentation, specifications and implementation details, see the [original repository](https://github.com/s1mb1o/step2gltf).

## Installation

### Install dependencies

```bash
sudo apt-get update && \
sudo apt-get install -y --no-install-recommends \
    build-essential cmake wget git \
    ca-certificates libcurl4 libuv1 \
    libfreetype6-dev tcl-dev tk-dev \
    libxmu-dev libxi-dev libgl1-mesa-dev xorg-dev \
    rapidjson-dev
```

### Install OpenCascade 7.9.1

```bash
wget https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_9_1.tar.gz
tar -xf V7_9_1.tar.gz
cd OCCT-7_9_1
mkdir build
cd build
cmake .. \
      -DUSE_RAPIDJSON=ON \
      -DBUILD_MODULE_Visualization=ON \
      -DBUILD_MODULE_Draw=OFF \
      -DBUILD_MODULE_DataExchange=ON \
      -DCMAKE_BUILD_TYPE=Release
make -j$(nproc) install
```

### Configure system libraries

To avoid having to specify `LD_LIBRARY_PATH` every time:

```bash
echo '/usr/local/lib' | sudo tee /etc/ld.so.conf.d/opencascade.conf
sudo ldconfig
```

### Compile step2gltf

```bash
make
```

## Usage

```bash
step2gltf STEPFILENAME GLTFFILENAME
```

Supported extensions:

- `.gltf` - glTF with binary resources embedded in JSON (base64)
- `.glb` - Binary glTF

## Changes made in this fork

- Updated for OpenCascade 7.9.1
- Code changes for compatibility:
  - `#include <Message_ProgressIndicator.hxx>` → `#include <Message_ProgressRange.hxx>`
  - `Message_ProgressIndicator(100)` → `Message_ProgressRange()`
  - Makefile libraries update (added `-lTKDEGLTF`, removed `-lTKRWGltf`)
