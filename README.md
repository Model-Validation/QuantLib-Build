# QuantLib SuperBuild System

This directory contains a unified CMake build system that integrates both QuantLib C++ library and QuantLib-SWIG Python bindings into a single, manageable build process.

## Overview

The unified build system replaces the separate build processes described in `quantlib_build.ps1` with CMake targets that can be executed from Visual Studio, VS Code, or the command line.

## Prerequisites

- CMake 3.20 or later
- Visual Studio 2019/2022 with MSVC or Clang
- Python 3.8+ with virtual environment at `C:/ws/venv312/`
- **SWIG 4.0+** (required for Python bindings)
- Boost 1.88.0 installed at `C:/local/boost_1_88_0/`
- Eigen3 installed via Chocolatey
- SCS library built at `C:/ws/git/scs/`
- delvewheel package for wheel repair

### Installing SWIG

If SWIG is not found, the system will automatically disable Python bindings and show installation instructions.

**Option 1: Install in Python Virtual Environment (Recommended)**
```powershell
# Activate your Python venv
C:/ws/venv312/Scripts/activate.ps1
# Install SWIG
pip install swig
```
The CMake system will automatically find SWIG in `C:/ws/venv312/Scripts/`.

**Option 2: Download and Extract**
1. Download SWIG from: https://www.swig.org/download.html
2. Extract to `C:/Program Files/swigwin-x.x.x/` or `C:/tools/swigwin-x.x.x/`
3. Add to PATH or specify location with `-DSWIG_EXECUTABLE=path/to/swig.exe`

**Option 3: Use Chocolatey**
```powershell
choco install swig
```

**Option 4: Use vcpkg**
```bash
vcpkg install swig
```

## Quick Start

### Using Visual Studio / VS Code

1. Open the `ql139` directory in Visual Studio or VS Code
2. Select a CMake preset (e.g., `windows-msvc-relwithdebinfo`)
3. Configure the project
4. Build individual targets or use `python_all` for complete Python build

### Using Command Line

```bash
# Configure with preset
cmake --preset windows-msvc-relwithdebinfo

# Build QuantLib library only
cmake --build build/windows-msvc-relwithdebinfo --target ql_library

# Build complete Python bindings
cmake --build build/windows-msvc-relwithdebinfo --target python_all
```

## Available Targets

### Core Targets
- **`ql_library`** - Builds the QuantLib C++ library (equivalent to original QuantLib CMake target)

### Python Binding Targets
- **`swig_generate`** - Generates Python SWIG bindings from `quantlib.i`
- **`python_compile`** - Compiles the Python C++ extension (build_ext)
- **`python_build`** - Builds Python modules and prepares for packaging  
- **`python_wheel`** - Creates the Python wheel package
- **`python_install`** - Repairs wheel with delvewheel and installs via pip
- **`python_all`** - Complete Python build and install process (runs all above targets in sequence)

## Configuration Presets

The system includes several CMake presets for different build configurations:

### Standard Presets (with Python bindings)
- `windows-msvc-release` - Release build with MSVC
- `windows-msvc-debug` - Debug build with MSVC  
- `windows-msvc-relwithdebinfo` - RelWithDebInfo build with MSVC
- `windows-clang-release` - Release build with Clang
- `windows-clang-debug` - Debug build with Clang
- `windows-clang-relwithdebinfo` - RelWithDebInfo build with Clang

### Library-Only Presets (C++ only, no Python)
- `library-only-release` - Build only QuantLib C++ library (no Python bindings)
- `library-only-debug` - Debug build of QuantLib C++ library only
- `no-swig-fallback` - Fallback preset when SWIG is not available

## Build Information Tracking

The unified build system automatically tracks and embeds build provenance information:

### QuantLib C++ Library
- **`QL_BUILD_USER`** - Automatically detected from `$USERNAME` (Windows) or `$USER` (Unix)
- **`QL_BUILD_MACHINE`** - Automatically detected from `$COMPUTERNAME` (Windows) or `hostname` (Unix)
- Accessible via `quantlibBuildInfo()` function in C++

### SWIG Python Bindings  
- **`SWIG_BUILD_USER`** and **`SWIG_BUILD_MACHINE`** - Passed as defines to SWIG
- **`QL_ENABLE_ISDA_CDS`** - Conditionally passed if ISDA CDS is enabled
- Accessible via `swigBuildInfo()` function in Python

### Python Library Linking
- **`LINK_DATE`** and **`LINK_TIME`** - Automatically replaced with current timestamp during SWIG post-processing
- Accessible via `python_library_info()` function in Python
- Combined info available via `get_full_build_info()` function

## Environment Variables

The build system automatically sets all required environment variables from your QuantLib presets:

- `BOOST_ROOT`, `BOOST`, `BOOST_INCLUDE_DIRS`, `BOOST_LIB64`
- `QL_*` configuration variables
- `EIGEN3_INCLUDE_DIR`, `scs_DIR`, `isda_cds_model_DIR`

## Customization

### Disabling Python Bindings

Set `BUILD_PYTHON_BINDINGS=OFF` in CMake configuration:

```bash
cmake --preset windows-msvc-release -DBUILD_PYTHON_BINDINGS=OFF
```

### Modifying Paths

Update the cache variables in `CMakeLists.txt` or override via command line:

```bash
cmake --preset windows-msvc-release -DBOOST="C:/path/to/your/boost"
```

## Granular Build Control

The Python build process is broken down into separate steps for better control:

1. **`swig_generate`** - Generate C++ wrapper from SWIG interface files
2. **`python_compile`** - Compile the massive quantlib_wrap.cpp (824K+ lines)
3. **`python_build`** - Build Python modules and prepare package structure
4. **`python_wheel`** - Create the wheel distribution file
5. **`python_install`** - Repair wheel dependencies and install via pip

This allows you to:
- Debug compilation issues at the C++ level
- Skip wheel creation if only testing compilation
- Manually inspect intermediate build artifacts
- Install from pre-built wheels without rebuilding

## Comparison with PowerShell Script

| PowerShell Script Step | CMake Target | Notes |
|------------------------|--------------|-------|
| Activate venv | All python_* | Handled automatically |
| Set environment variables | Configuration | Set during CMake configure |  
| Run SWIG with build defines | `swig_generate` | Includes SWIG_BUILD_USER, SWIG_BUILD_MACHINE, QL_ENABLE_ISDA_CDS |
| Post-process QuantLib.py | `swig_generate` | Automatic LINK_DATE/LINK_TIME replacement |
| Compile C++ extension | `python_compile` | Uses setup.py build_ext |
| Build Python modules | `python_build` | Uses setup.py build |
| Create wheel | `python_wheel` | Uses setup.py bdist_wheel |
| Repair wheel + pip install | `python_install` | Combined delvewheel + pip |

## Troubleshooting

### Common Issues

1. **SWIG not found**: 
   - CMake will show: `Could NOT find SWIG (missing: SWIG_EXECUTABLE SWIG_DIR)`
   - Solution: Install SWIG 4.0+ and add to PATH, or use a library-only preset
   - Alternative: Use `-DSWIG_EXECUTABLE=C:/path/to/swig.exe` to specify location

2. **Python environment**: Verify virtual environment exists at `C:/ws/venv312/`

3. **Boost not found**: Check Boost installation paths in presets

4. **Build failures**: Check that all dependencies (SCS, Eigen3, etc.) are properly installed

5. **Python bindings disabled**: If SWIG isn't found, the system automatically falls back to library-only mode

### Build Configuration

The system uses the same configuration as your original QuantLib presets:
- Boost 1.88.0 (no std:: equivalents - uses Boost versions)
- Static runtime linking
- All dependency paths consistent between QuantLib and Python builds

## Integration with IDEs

### Visual Studio
- Open folder at `ql139` level
- CMake integration will detect presets automatically
- Build targets available in Solution Explorer

### VS Code
- Install CMake Tools extension
- Open folder at `ql139` level  
- Use Command Palette for CMake operations
- Targets available in CMake sidebar

This unified system maintains all the functionality of your original PowerShell script while providing better IDE integration and dependency management.

## Deprecated Files

The following PowerShell scripts have been replaced by the unified CMake build system:
- `quantlib_build.ps1` - Use CMake target `python_all` instead
- `quantlib_superbuild.ps1` - Use CMake presets with appropriate targets
- `compile_ql_swig_new.ps1` - Use CMake target `swig_generate` with ISDA support
- `build_with_isda.ps1` - ISDA support is handled automatically by CMake when configured