#include <benchmark/benchmark.h>
#include <linalg/matrix.hpp>

static void BM_NaiveMultiply(benchmark::State& state) {
    std::size_t n = state.range(0);
    Matrix<double> a(std::vector<double>(n * n, 1.0), n, n);
    Matrix<double> b(std::vector<double>(n * n, 2.0), n, n);
    for (auto _ : state) {
        benchmark::DoNotOptimize(a * b);
    }
}
BENCHMARK(BM_NaiveMultiply)->Arg(64)->Arg(128)->Arg(256)->Arg(512);