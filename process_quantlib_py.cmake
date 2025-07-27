# CMake script to post-process QuantLib.py with build timestamp information
# This script replaces LINK_DATE and LINK_TIME placeholders with actual build time

# Get current date and time (local time, not UTC, to match __DATE__ and __TIME__)
string(TIMESTAMP LINK_DATE "%b %d %Y")  # Format: "MMM dd yyyy" e.g., "Jul 25 2025"
string(TIMESTAMP LINK_TIME "%H:%M:%S")  # Format: "HH:mm:ss" e.g., "11:01:28"

# Path to the generated QuantLib.py file (relative to QuantLib-SWIG/Python working directory)
set(QUANTLIB_PY_PATH "src/QuantLib/QuantLib.py")

# Check if QuantLib.py exists
if(NOT EXISTS "${QUANTLIB_PY_PATH}")
    message(FATAL_ERROR "QuantLib.py not found at: ${QUANTLIB_PY_PATH}")
endif()

message(STATUS "Post-processing QuantLib.py with timestamp: ${LINK_DATE} ${LINK_TIME}")

# Read the content of QuantLib.py
file(READ "${QUANTLIB_PY_PATH}" QUANTLIB_CONTENT)

# Replace LINK_DATE and LINK_TIME placeholders
string(REPLACE 
    "link_date : str = \"LINK_DATE\"" 
    "link_date : str = \"${LINK_DATE}\"" 
    QUANTLIB_CONTENT "${QUANTLIB_CONTENT}")

string(REPLACE 
    "link_time : str = \"LINK_TIME\"" 
    "link_time : str = \"${LINK_TIME}\"" 
    QUANTLIB_CONTENT "${QUANTLIB_CONTENT}")

# Write the updated content back to QuantLib.py
file(WRITE "${QUANTLIB_PY_PATH}" "${QUANTLIB_CONTENT}")

message(STATUS "QuantLib.py updated successfully with build timestamp")