include(FetchContent)
set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
  benchmark
  URL https://github.com/google/benchmark/archive/refs/tags/v1.8.3.zip
)
FetchContent_MakeAvailable(benchmark)

add_executable(bench_matrix bench_matrix.cpp)
target_link_libraries(bench_matrix PRIVATE linalg benchmark::benchmark_main)