cmake_minimum_required(VERSION 3.10)
# project(TargetEngine NONE)
project(TargetEngine C)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/")
set(DART_SRC "${CMAKE_CURRENT_SOURCE_DIR}/bin/main.dart")
set(DART_OUT "${CMAKE_CURRENT_SOURCE_DIR}/build")

file(MAKE_DIRECTORY ${DART_OUT})

# IOT CONFIG
add_custom_target(run_debug COMMAND dart run --enable-asserts "${DART_SRC}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" COMMENT "Executing dart in JIT (Debug) mode")
# AOT CONFIG
add_custom_target(build_aot COMMAND dart compile exe "${DART_SRC}" COMMENT "Compiling project AOT")