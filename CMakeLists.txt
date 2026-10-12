cmake_minimum_required(VERSION 3.16)
project(linalg LANGUAGES CXX)

# C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Default to Release so benchmarks aren't run in a debug build
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Header-only library: nothing to compile, just exposes include/
add_library(linalg INTERFACE)
target_include_directories(linalg INTERFACE include)

# Tests
enable_testing()
add_subdirectory(tests)