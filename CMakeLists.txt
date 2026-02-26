cmake_minimum_required(VERSION 3.10)
project(TargetEngine C)


# Output path 
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src")
# JIT and AOT modes
set(DART_SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/main.dart")
set(DART_OUT "${CMAKE_CURRENT_SOURCE_DIR}/bin")
file(MAKE_DIRECTORY ${DART_OUT})

# C files to compile
file(GLOB NATIVE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")
# add_library(nuklear_layout SHARED "${NATIVE_SOURCES}")
# set_target_properties(nuklear_layout PROPERTIES PREFIX "" IMPORT_PREFIX "" RUNTIME_OUTPUT_DIRECTORY "${DART_OUT}")

# # IOT CONFIG
# add_custom_target(
# 	run_debug 
# 	COMMAND dart run --enable-asserts "${DART_SRC}"
# 	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
# 	COMMENT "Executing dart in JIT (Debug) mode"
# )
# AOT CONFIG
add_custom_target(build_aot COMMAND dart compile exe "${DART_SRC}" COMMENT "Compiling project AOT")