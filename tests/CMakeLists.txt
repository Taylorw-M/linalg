include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
FetchContent_MakeAvailable(googletest)

add_executable(test_matrix test_matrix.cpp)
target_link_libraries(test_matrix PRIVATE linalg GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(test_matrix)