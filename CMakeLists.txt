cmake_minimum_required(VERSION 3.10)
project(TargetEngine C)

# ============================================================================
# Configuration
# ============================================================================
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")

set(DART_SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/main.dart")
set(DART_OUT "${CMAKE_CURRENT_SOURCE_DIR}/bin")
file(MAKE_DIRECTORY ${DART_OUT})

# ============================================================================
# C/Native Library Configuration
# ============================================================================
file(GLOB NATIVE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")

# Only create library if C sources exist
if(NATIVE_SOURCES)
    message(STATUS "Found C sources: ${NATIVE_SOURCES}")
    
    add_library(target_native SHARED ${NATIVE_SOURCES})
    
    # Compiler flags for better performance and warnings
    target_compile_options(target_native PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:/W4>
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -pedantic>
        $<$<CONFIG:Release>:-O3>
        $<$<CONFIG:Debug>:-g -O0>
    )
    
    # Library properties
    set_target_properties(target_native PROPERTIES
        PREFIX ""
        IMPORT_PREFIX ""
        RUNTIME_OUTPUT_DIRECTORY "${DART_OUT}"
        LIBRARY_OUTPUT_DIRECTORY "${DART_OUT}"
    )
    
    message(STATUS "Native library target 'target_native' configured")
else()
    message(STATUS "No C sources found in src/ - native library will not be built")
endif()

# ============================================================================
# Dart Compilation Targets
# ============================================================================

# AOT compilation target (Release build)
add_custom_target(build_aot 
    COMMAND dart compile exe "${DART_SRC}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Compiling Dart project to AOT executable"
)

# JIT development target
add_custom_target(run_jit 
    COMMAND dart run --enable-asserts "${DART_SRC}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Running Dart in JIT (Debug) mode with assertions"
)

# Default target
if(NATIVE_SOURCES)
    add_custom_target(build_all 
        DEPENDS target_native build_aot
        COMMENT "Building native library and Dart AOT"
    )
else()
    add_custom_target(build_all 
        DEPENDS build_aot
        COMMENT "Building Dart AOT (no native sources found)"
    )
endif()