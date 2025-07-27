cmake_minimum_required(VERSION 3.20)
project(QuantLibSuperBuild VERSION 1.39.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Option to enable Python bindings
option(BUILD_PYTHON_BINDINGS "Build Python bindings via SWIG" ON)

# Find required packages
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

# Set Python virtual environment path if not already set
set(PYTHON_VENV_PATH "C:/ws/venv312" CACHE PATH "Python virtual environment path")

# Detect build user and machine information using execute_process for reliability
message(STATUS "Detecting build user and machine information...")

if(WIN32)
    # Use execute_process for more reliable detection on Windows
    execute_process(
        COMMAND cmd /c "echo %USERNAME%"
        OUTPUT_VARIABLE BUILD_USER_RAW
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    execute_process(
        COMMAND cmd /c "echo %COMPUTERNAME%"
        OUTPUT_VARIABLE BUILD_MACHINE_RAW  
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
else()
    # Use standard Unix commands
    execute_process(
        COMMAND whoami
        OUTPUT_VARIABLE BUILD_USER_RAW
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    execute_process(
        COMMAND hostname
        OUTPUT_VARIABLE BUILD_MACHINE_RAW
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
endif()

# Clean up the values and set fallbacks
string(STRIP "${BUILD_USER_RAW}" BUILD_USER)
string(STRIP "${BUILD_MACHINE_RAW}" BUILD_MACHINE)

if("${BUILD_USER}" STREQUAL "" OR "${BUILD_USER}" STREQUAL "%USERNAME%")
    set(BUILD_USER "UnknownUser")
    message(WARNING "Could not detect build user, using fallback: ${BUILD_USER}")
else()
    message(STATUS "Build user detected: ${BUILD_USER}")
endif()

if("${BUILD_MACHINE}" STREQUAL "" OR "${BUILD_MACHINE}" STREQUAL "%COMPUTERNAME%")
    set(BUILD_MACHINE "UnknownMachine")  
    message(WARNING "Could not detect build machine, using fallback: ${BUILD_MACHINE}")
else()
    message(STATUS "Build machine detected: ${BUILD_MACHINE}")
endif()

# Set CMake cache variables from QuantLib presets (windows-base)
set(EIGEN3_INCLUDE_DIR "C:/ProgramData/chocolatey/lib/eigen/include/eigen3/" CACHE PATH "Eigen3 include directory")
set(scs_DIR "C:/ws/git/scs/out/build/x64-Debug/" CACHE PATH "SCS directory")
set(isda_cds_model_DIR "C:/ws/libraries/isda_cds_model_c_v1.8.3/build" CACHE PATH "ISDA CDS model directory")
set(QL_BOOST_VERSION "1.88.0" CACHE STRING "Boost version")
set(QL_USE_STD_SHARED_PTR "ON" CACHE BOOL "Use std::shared_ptr")
set(QL_USE_STD_ANY "ON" CACHE BOOL "Use std::any")
set(QL_USE_STD_OPTIONAL "ON" CACHE BOOL "Use std::optional")
set(QL_BUILD_TEST_SUITE "OFF" CACHE BOOL "Build test suite")
set(QL_BUILD_EXAMPLES "OFF" CACHE BOOL "Build examples")
set(QL_ENABLE_ISDA_CDS "ON" CACHE BOOL "Enable ISDA CDS")
set(BOOST "C:/local/boost_1_88_0" CACHE PATH "Boost root directory")
set(BOOST_INCLUDE_DIRS "C:/local/boost_1_88_0/boost" CACHE PATH "Boost include directories")
set(BOOST_LIB64 "C:/local/boost_1_88_0/lib64-msvc-14.3" CACHE PATH "Boost lib64 directory")

# Pass build information to QuantLib
set(QL_BUILD_USER "${BUILD_USER}" CACHE STRING "User building QuantLib")
set(QL_BUILD_MACHINE "${BUILD_MACHINE}" CACHE STRING "Machine building QuantLib")

# Set environment variables for consistent builds (from QuantLib presets)
set(ENV{BOOST_ROOT} "C:/local/boost_1_88_0/lib64-msvc-14.3/cmake/Boost-1.88.0")
set(ENV{BOOST} "C:/local/boost_1_88_0")
set(ENV{BOOST_INCLUDE_DIRS} "C:/local/boost_1_88_0/boost")
set(ENV{BOOST_LIB64} "C:/local/boost_1_88_0/lib64-msvc-14.3")
set(ENV{QL_STATIC_RUNTIME} "ON")

# Add QuantLib subdirectory
add_subdirectory(QuantLib)

# Force version.cpp recompilation to get fresh timestamp
add_custom_target(force_version_rebuild
    COMMAND ${CMAKE_COMMAND} -E echo "Forcing version.cpp recompilation for fresh build timestamp"
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib/ql/version.cpp
    COMMENT "Force version.cpp rebuild for current timestamp"
)
add_dependencies(ql_library force_version_rebuild)

# Pass build info as compile definitions to QuantLib (with proper quoting)
target_compile_definitions(ql_library PRIVATE
    "QL_BUILD_USER=\"${BUILD_USER}\""
    "QL_BUILD_MACHINE=\"${BUILD_MACHINE}\""
)

# Create convenience alias for the main library target
add_library(QuantLib::QuantLib ALIAS ql_library)

if(BUILD_PYTHON_BINDINGS)
    # Find SWIG - try to locate it in common locations
    find_package(SWIG 4.0 QUIET)
    
    if(NOT SWIG_FOUND)
        # Try to find SWIG manually - first check Python venv, then common Windows locations
        find_program(SWIG_EXECUTABLE
            NAMES swig.exe swig
            HINTS 
                "${PYTHON_VENV_PATH}/Scripts"  # Check Python venv first
                "C:/ws/venv312/Scripts"  # Fallback to hardcoded path
                "${Python3_PREFIX}/Scripts"  # Alternative Python location
                "C:/Program Files/swigwin-4.2.1"
                "C:/Program Files/swigwin-4.2.0" 
                "C:/Program Files/swigwin-4.1.1"
                "C:/Program Files/swigwin-4.1.0"
                "C:/Program Files/swigwin-4.0.2"
                "C:/Program Files/swigwin-4.0.1"
                "C:/Program Files/swigwin-4.0.0"
                "C:/swigwin-4.2.1"
                "C:/swigwin-4.2.0"
                "C:/swigwin-4.1.1" 
                "C:/swigwin-4.1.0"
                "C:/swigwin-4.0.2"
                "C:/swigwin-4.0.1"
                "C:/swigwin-4.0.0"
                "C:/tools/swigwin-4.2.1"
                "C:/tools/swigwin-4.2.0"
                "C:/tools/swigwin-4.1.1"
                "C:/tools/swigwin-4.1.0"
                "C:/tools/swigwin-4.0.2"
                "C:/tools/swigwin-4.0.1"
                "C:/tools/swigwin-4.0.0"
            PATHS ENV PATH
            DOC "SWIG executable"
        )
        
        if(SWIG_EXECUTABLE)
            # Get SWIG version
            execute_process(COMMAND ${SWIG_EXECUTABLE} -version 
                OUTPUT_VARIABLE SWIG_VERSION_OUTPUT 
                ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
            
            if(SWIG_VERSION_OUTPUT MATCHES "SWIG Version ([0-9]+\\.[0-9]+\\.[0-9]+)")
                set(SWIG_VERSION ${CMAKE_MATCH_1})
                message(STATUS "Found SWIG: ${SWIG_EXECUTABLE} (version ${SWIG_VERSION})")
                
                # Check if version is sufficient
                if(SWIG_VERSION VERSION_GREATER_EQUAL "4.0.0")
                    set(SWIG_FOUND TRUE)
                else()
                    message(WARNING "SWIG version ${SWIG_VERSION} found, but version 4.0+ required")
                    set(SWIG_FOUND FALSE)
                endif()
            else()
                message(WARNING "Could not determine SWIG version")
                set(SWIG_FOUND FALSE)
            endif()
        endif()
    endif()
    
    if(SWIG_FOUND)
        include(UseSWIG)
        message(STATUS "SWIG found: ${SWIG_EXECUTABLE}")
    else()
        message(WARNING "SWIG 4.0+ not found. Python bindings will be disabled.")
        message(WARNING "To enable Python bindings, install SWIG using one of these methods:")
        message(WARNING "  1. If using Python venv: pip install swig (then reconfigure)")
        message(WARNING "  2. Download from: https://www.swig.org/download.html")
        message(WARNING "  3. Extract to C:/Program Files/swigwin-x.x.x/")
        message(WARNING "  4. Or specify location with -DSWIG_EXECUTABLE=C:/ws/venv312/Scripts/swig.exe")
        set(BUILD_PYTHON_BINDINGS OFF)
    endif()
endif()

if(BUILD_PYTHON_BINDINGS AND SWIG_FOUND)
    # Configure-time banner (shown when CMake configures)
    message(STATUS "")
    message(STATUS "==========================================")
    message(STATUS "QuantLib SuperBuild Configuration Complete")  
    message(STATUS "Run 'python_all' target to start build process")
    message(STATUS "==========================================")
    message(STATUS "")

    # SWIG target for generating Python bindings
    add_custom_target(swig_generate
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 2/6] #### Generating SWIG Python bindings... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${SWIG_EXECUTABLE} -python -c++ 
            "-DSWIG_BUILD_USER=\"${BUILD_USER}\""
            "-DSWIG_BUILD_MACHINE=\"${BUILD_MACHINE}\""
            $<$<BOOL:${QL_ENABLE_ISDA_CDS}>:-DQL_ENABLE_ISDA_CDS>
            -outdir "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python/src/QuantLib"
            -o "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python/src/QuantLib/quantlib_wrap.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/SWIG/quantlib.i"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generate Python SWIG bindings from interface files"
        DEPENDS ql_library ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/SWIG/quantlib.i
    )

    # Python compile target - compile the C++ extension only
    add_custom_target(python_compile
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 3/6] #### Compiling Python C++ extension (this may take several minutes)... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E env 
            "BOOST_ROOT=${BOOST}/lib64-msvc-14.3/cmake/Boost-1.88.0"
            "BOOST=${BOOST}"
            "BOOST_INCLUDE_DIRS=${BOOST_INCLUDE_DIRS}"
            "BOOST_LIB64=${BOOST_LIB64}"
            "QL_DIR=C:/ws/git/ql139/QuantLib/build/install/include"
            "LIB=C:/ws/git/scs/build/lib/RelWithDebInfo;C:/ws/git/ql139/QuantLib/build/windows-msvc-relwithdebinfo/ql"
            "INCLUDE=${BOOST};${EIGEN3_INCLUDE_DIR};C:/ws/git/scs/include"
            "QL_STATIC_RUNTIME=ON"
            "QL_BOOST_VERSION=${QL_BOOST_VERSION}"
            "QL_USE_STD_SHARED_PTR=${QL_USE_STD_SHARED_PTR}"
            "QL_USE_STD_ANY=${QL_USE_STD_ANY}"
            "QL_USE_STD_OPTIONAL=${QL_USE_STD_OPTIONAL}"
            "QL_ENABLE_ISDA_CDS=${QL_ENABLE_ISDA_CDS}"
            "ISDA_CDS_ROOT=C:/ws/libraries/isda_cds_model_c_v1.8.3"
            ${PYTHON_VENV_PATH}/Scripts/python.exe setup.py build_ext
        COMMAND ${CMAKE_COMMAND} -E echo "Post-processing QuantLib.py with build timestamp..."
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/process_quantlib_py.cmake"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python
        COMMENT "Step 3: Compile C++ extension and update timestamps"
        DEPENDS swig_generate
    )

    # Python build target - build Python modules and prepare for packaging
    add_custom_target(python_build
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 4/6] #### Building Python modules and preparing package structure... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E env 
            "BOOST_ROOT=${BOOST}/lib64-msvc-14.3/cmake/Boost-1.88.0"
            "BOOST=${BOOST}"
            "BOOST_INCLUDE_DIRS=${BOOST_INCLUDE_DIRS}"
            "BOOST_LIB64=${BOOST_LIB64}"
            "QL_DIR=C:/ws/git/ql139/QuantLib/build/install/include"
            "LIB=C:/ws/git/scs/build/lib/RelWithDebInfo;C:/ws/git/ql139/QuantLib/build/windows-msvc-relwithdebinfo/ql"
            "INCLUDE=${BOOST};${EIGEN3_INCLUDE_DIR};C:/ws/git/scs/include"
            "QL_STATIC_RUNTIME=ON"
            "QL_BOOST_VERSION=${QL_BOOST_VERSION}"
            "QL_USE_STD_SHARED_PTR=${QL_USE_STD_SHARED_PTR}"
            "QL_USE_STD_ANY=${QL_USE_STD_ANY}"
            "QL_USE_STD_OPTIONAL=${QL_USE_STD_OPTIONAL}"
            "QL_ENABLE_ISDA_CDS=${QL_ENABLE_ISDA_CDS}"
            "ISDA_CDS_ROOT=C:/ws/libraries/isda_cds_model_c_v1.8.3"
            ${PYTHON_VENV_PATH}/Scripts/python.exe setup.py build
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python
        COMMENT "Step 4: Build Python modules and prepare package structure"
        DEPENDS python_compile
    )

    # Python wheel creation target
    add_custom_target(python_wheel
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 5/6] #### Creating Python wheel package... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E env 
            "BOOST_ROOT=${BOOST}/lib64-msvc-14.3/cmake/Boost-1.88.0"
            "BOOST=${BOOST}"
            "BOOST_INCLUDE_DIRS=${BOOST_INCLUDE_DIRS}"
            "BOOST_LIB64=${BOOST_LIB64}"
            "QL_DIR=C:/ws/git/ql139/QuantLib/build/install/include"
            "LIB=C:/ws/git/scs/build/lib/RelWithDebInfo;C:/ws/git/ql139/QuantLib/build/windows-msvc-relwithdebinfo/ql"
            "INCLUDE=${BOOST};${EIGEN3_INCLUDE_DIR};C:/ws/git/scs/include"
            "QL_STATIC_RUNTIME=ON"
            "QL_BOOST_VERSION=${QL_BOOST_VERSION}"
            "QL_USE_STD_SHARED_PTR=${QL_USE_STD_SHARED_PTR}"
            "QL_USE_STD_ANY=${QL_USE_STD_ANY}"
            "QL_USE_STD_OPTIONAL=${QL_USE_STD_OPTIONAL}"
            "QL_ENABLE_ISDA_CDS=${QL_ENABLE_ISDA_CDS}"
            "ISDA_CDS_ROOT=C:/ws/libraries/isda_cds_model_c_v1.8.3"
            ${PYTHON_VENV_PATH}/Scripts/python.exe setup.py bdist_wheel
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python
        COMMENT "Step 5: Create Python wheel distribution package"
        DEPENDS python_build
    )

    # Combined install target - repair wheel and install it
    add_custom_target(python_install
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 6/6] #### Repairing wheel and installing QuantLib Python package... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${PYTHON_VENV_PATH}/Scripts/delvewheel.exe repair 
            --add-path "C:/ws/git/scs/build/lib/RelWithDebInfo"
            "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python/dist/quantlib-1.39.dev0-cp38-abi3-win_amd64.whl"
        COMMAND ${CMAKE_COMMAND} -E echo "Installing repaired wheel..."
        COMMAND ${PYTHON_VENV_PATH}/Scripts/python.exe -m pip install --force-reinstall
            "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python/wheelhouse/quantlib-1.39.dev0-cp38-abi3-win_amd64.whl"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG/Python
        COMMENT "Step 6: Repair wheel dependencies and install QuantLib package"
        DEPENDS python_wheel
    )

    # Step 1 announcement target (shows when QuantLib build is about to start)
    add_custom_target(announce_step1
        COMMAND ${CMAKE_COMMAND} -E echo "=========================================="
        COMMAND ${CMAKE_COMMAND} -E echo "Starting QuantLib SuperBuild Process"
        COMMAND ${CMAKE_COMMAND} -E echo "=========================================="
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "[Step 1/6] #### Building QuantLib C++ library... ####"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMENT "SuperBuild: Show initial banner and Step 1 announcement"
    )

    # Completion message target  
    add_custom_target(announce_completion
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "✓ QuantLib SuperBuild completed successfully!"
        COMMAND ${CMAKE_COMMAND} -E echo "Run 'python -c \"import QuantLib as ql; print(ql.get_full_build_info())\"' to verify"
        COMMAND ${CMAKE_COMMAND} -E echo "=========================================="
        COMMENT "SuperBuild: Show completion message"
        DEPENDS python_install
    )

    # Create proper dependency chain: announce_step1 → ql_library → swig_generate → ... → announce_completion
    add_dependencies(ql_library announce_step1)
    
    # Convenience target for full Python build and install
    add_custom_target(python_all
        COMMENT "Build QuantLib C++ library and Python bindings, then install"
        DEPENDS announce_completion
    )
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "======================================")
message(STATUS "QuantLib SuperBuild Configuration:")
message(STATUS "======================================")
message(STATUS "  Build Python bindings: ${BUILD_PYTHON_BINDINGS}")
message(STATUS "  Python executable: ${Python3_EXECUTABLE}")
message(STATUS "  Python version: ${Python3_VERSION}")
message(STATUS "")
message(STATUS "Build Information:")
message(STATUS "  Build user: ${BUILD_USER}")
message(STATUS "  Build machine: ${BUILD_MACHINE}")
message(STATUS "  Will be passed to QuantLib as: QL_BUILD_USER=\"${BUILD_USER}\" QL_BUILD_MACHINE=\"${BUILD_MACHINE}\"")
message(STATUS "  Will be passed to SWIG as: SWIG_BUILD_USER=\"${BUILD_USER}\" SWIG_BUILD_MACHINE=\"${BUILD_MACHINE}\"")
message(STATUS "")
message(STATUS "QuantLib Configuration:")
message(STATUS "  Boost version: ${QL_BOOST_VERSION}")
message(STATUS "  Use std::shared_ptr: ${QL_USE_STD_SHARED_PTR}")
message(STATUS "  Use std::any: ${QL_USE_STD_ANY}")
message(STATUS "  Use std::optional: ${QL_USE_STD_OPTIONAL}")
message(STATUS "  Enable ISDA CDS: ${QL_ENABLE_ISDA_CDS}")
message(STATUS "  Build test suite: ${QL_BUILD_TEST_SUITE}")
message(STATUS "  Build examples: ${QL_BUILD_EXAMPLES}")
message(STATUS "")
message(STATUS "Dependency Paths:")
message(STATUS "  Boost root: ${BOOST}")
message(STATUS "  Eigen3 include: ${EIGEN3_INCLUDE_DIR}")
message(STATUS "  SCS directory: ${scs_DIR}")
if(QL_ENABLE_ISDA_CDS)
    message(STATUS "  ISDA CDS model: ${isda_cds_model_DIR}")
endif()

# Available targets summary
message(STATUS "")
message(STATUS "Available targets:")
message(STATUS "  ql_library       - Build QuantLib C++ library")
if(BUILD_PYTHON_BINDINGS)
    message(STATUS "  swig_generate    - Generate SWIG Python bindings")
    message(STATUS "  python_compile   - Compile Python C++ extension")
    message(STATUS "  python_build     - Build Python modules")
    message(STATUS "  python_wheel     - Create Python wheel")
    message(STATUS "  python_install   - Repair wheel and install package")
    message(STATUS "  python_all       - Complete Python build and install")
endif()
message(STATUS "======================================")