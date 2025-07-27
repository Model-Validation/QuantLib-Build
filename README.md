# QuantLib SuperBuild System

A unified CMake build system that seamlessly integrates the QuantLib C++ library and QuantLib-SWIG Python bindings into a single, streamlined build process.

## Overview

This build system provides a modern CMake-based approach to building the Model-Validation forks of QuantLib and its Python bindings. It handles all dependencies, automates the SWIG generation process, and produces ready-to-use Python wheels.

## Prerequisites

### Required Tools
- **CMake** 3.20 or later
- **Visual Studio** 2019/2022 with MSVC or Clang
- **Python** 3.8+ with pip
- **Git** for cloning repositories

### Required Dependencies
- **Boost** 1.70+ (headers and libraries)
- **Eigen3** linear algebra library
- **SCS** (Splitting Conic Solver) for convex optimization
- **SWIG** 4.0+ for Python bindings generation

### Optional Dependencies
- **ISDA CDS Model** for credit derivatives support

## Quick Start

### 1. Clone the Build System

```bash
git clone https://github.com/Model-Validation/QuantLib-Build.git
cd QuantLib-Build
```

### 2. Clone QuantLib and QuantLib-SWIG as Subdirectories

```bash
git clone https://github.com/Model-Validation/QuantLib.git
git clone https://github.com/Model-Validation/QuantLib-SWIG.git
```

### 3. Configure the Build

```bash
cmake --preset windows-msvc-release
```

### 4. Build Everything

```bash
# Build QuantLib C++ library only
cmake --build build/windows-msvc-release --target ql_library

# Build complete Python package
cmake --build build/windows-msvc-release --target python_all
```

## Available Build Targets

### Core Library
- **`ql_library`** - Builds the QuantLib C++ static library

### Python Bindings
- **`python_all`** - Complete Python build pipeline (recommended)
- **`swig_generate`** - Generates Python wrapper code from SWIG interfaces
- **`python_compile`** - Compiles the C++ Python extension
- **`python_build`** - Builds the Python package structure
- **`python_wheel`** - Creates the distributable wheel file
- **`python_install`** - Installs the wheel into your Python environment

## Configuration Presets

### Full Build Presets (C++ Library + Python)
- `windows-msvc-release` - Optimized release build with MSVC
- `windows-msvc-debug` - Debug build with full symbols
- `windows-msvc-relwithdebinfo` - Release with debug info (recommended)
- `windows-clang-release` - Release build using Clang
- `windows-clang-debug` - Debug build using Clang

### Library-Only Presets (C++ only)
- `library-only-release` - Just the C++ library, no Python
- `library-only-debug` - Debug C++ library only

## Dependency Configuration

### Setting Dependency Paths

The build system searches for dependencies in standard locations. You can override these by setting CMake variables:

```bash
cmake --preset windows-msvc-release \
  -DBOOST_ROOT="C:/path/to/boost" \
  -DEIGEN3_INCLUDE_DIR="C:/path/to/eigen3" \
  -Dscs_DIR="C:/path/to/scs/lib/cmake/scs"
```

### Installing Dependencies

#### Windows (with Chocolatey)
```powershell
choco install boost-msvc-14.3 eigen swig
```

#### Windows (with vcpkg)
```powershell
vcpkg install boost:x64-windows eigen3:x64-windows
```

#### Ubuntu/Debian
```bash
sudo apt-get install libboost-all-dev libeigen3-dev swig
```

## Advanced Usage

### Building with ISDA CDS Support

If you have the ISDA CDS model library installed:

```bash
cmake --preset windows-msvc-release \
  -Disda_cds_model_DIR="C:/path/to/isda_cds_model"
```

### Custom Python Environment

To use a specific Python installation:

```bash
cmake --preset windows-msvc-release \
  -DPython3_EXECUTABLE="C:/path/to/python.exe"
```

### Parallel Builds

Speed up compilation with parallel jobs:

```bash
cmake --build build/windows-msvc-release --target python_all --parallel 8
```

## Build Information Tracking

The build system automatically embeds metadata into the compiled libraries:

- **Build timestamp** - When the library was built
- **Build user/machine** - Who built it and where
- **Configuration details** - Which features were enabled

Access this information in Python:
```python
import QuantLib as ql
print(ql.get_full_build_info())
```

## Troubleshooting

### SWIG Not Found
If CMake reports `Could NOT find SWIG`:
1. Install SWIG 4.0 or later
2. Add SWIG to your PATH, or
3. Specify the path: `-DSWIG_EXECUTABLE=C:/path/to/swig.exe`

### Missing Dependencies
The build will fail if required dependencies aren't found. Check the CMake output for specific error messages about missing packages.

### Python Import Errors
If the built module won't import:
1. Ensure all runtime dependencies are available
2. Check that the Python version matches your environment
3. On Windows, you may need to install Visual C++ Redistributables

## Project Structure

```
QuantLib-Build/
├── CMakeLists.txt           # Main build configuration
├── CMakePresets.json        # Predefined build configurations
├── process_quantlib_py.cmake # Helper for Python timestamp injection
├── README.md               # This file
├── QuantLib/               # C++ library source (cloned as subdirectory)
│   └── ...
└── QuantLib-SWIG/         # Python bindings source (cloned as subdirectory)
    └── ...
```

## Contributing

This build system is maintained as part of the Model-Validation QuantLib ecosystem. For issues or improvements, please open an issue on the respective GitHub repository.

## License

This build system is provided under the same BSD-style license as QuantLib. See LICENSE file for details.