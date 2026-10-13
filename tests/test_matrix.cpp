#include <gtest/gtest.h>
#include <linalg/matrix.hpp>

TEST(Matrix, TransposeShapeAndValues) {
    Matrix<int> a({1, 2, 3, 4, 5, 6}, 2, 3);   // rows: 1 2 3 / 4 5 6
    Matrix<int> t = a.transpose();

    EXPECT_EQ(t.rows(), 3u);
    EXPECT_EQ(t.cols(), 2u);
    EXPECT_EQ(t(0, 0), 1);
    EXPECT_EQ(t(0, 1), 4);
    EXPECT_EQ(t(1, 0), 2);
    EXPECT_EQ(t(2, 1), 6);
}

TEST(Matrix, DoubleTransposeIsOriginal) {
    Matrix<int> a({1, 2, 3, 4, 5, 6}, 2, 3);
    Matrix<int> back = a.transpose().transpose();

    EXPECT_EQ(back.rows(), 2u);
    EXPECT_EQ(back.cols(), 3u);
    for (std::size_t i = 0; i < 2; i++)
        for (std::size_t j = 0; j < 3; j++)
            EXPECT_EQ(back(i, j), a(i, j));
}