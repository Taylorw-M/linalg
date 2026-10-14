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

TEST(Matrix, MultiplyKnownResult){
     Matrix<int> a({1,2,3,4,5,6}, 2, 3);
    Matrix<int> b({7,8,9,10,11,12}, 3, 2);
    Matrix<int> c = a * b;
    EXPECT_EQ(c.rows(), 2u);
    EXPECT_EQ(c.cols(), 2u);
    EXPECT_EQ(c(0,0), 58);
    EXPECT_EQ(c(0,1), 64);
    EXPECT_EQ(c(1,0), 139);
    EXPECT_EQ(c(1,1), 154);
}

TEST(Matrix, MultiplyMismatchThrows) {
    Matrix<int> a({1,2,3,4,5,6}, 2, 3);
    EXPECT_THROW(a * a, std::invalid_argument);
}

TEST(Matrix, MultiplyByIdentity) {
    Matrix<int> a({1,2,3,4}, 2, 2);
    Matrix<int> id({1,0,0,1}, 2, 2);
    Matrix<int> c = a * id;
    for (std::size_t i = 0; i < 2; i++)
        for (std::size_t j = 0; j < 2; j++)
            EXPECT_EQ(c(i,j), a(i,j));
}

TEST(Matrix, OnebyOneMultiply){
    Matrix<int> a({2},1,1);
    Matrix<int> b({3},1,1);

    Matrix<int> c = a * b;

    EXPECT_EQ(c(0,0), 6);
}

TEST(Matrix, OnebyOneAdd){
    Matrix<int> a({2},1,1);
    Matrix<int> b({3},1,1);

    Matrix<int> c = a + b;

    EXPECT_EQ(c(0,0), 5);
}

TEST(Matrix, OnebyOneSubtract){
    Matrix<int> a({2},1,1);
    Matrix<int> b({3},1,1);

    Matrix<int> c = a - b;

    EXPECT_EQ(c(0,0), -1);
}

TEST(Matrix, OnebyOneTranspose){
    Matrix<int> a({2}, 1,1);
    Matrix<int> c = a.transpose();
    
    EXPECT_EQ(c(0,0), 2);
    EXPECT_EQ(c.rows(), 1u);
    EXPECT_EQ(c.cols(), 1u);
}

TEST(Matrix, AddMismatchThrows) {
       Matrix<int> a({1,2,3,4,5,6}, 2, 3);
       Matrix<int> b({1,2,3,4,5,6}, 3, 2);
       EXPECT_THROW(a + b, std::invalid_argument);
       EXPECT_THROW(a - b, std::invalid_argument);
}

TEST(Matrix, ScalarMultiply){
    Matrix<int> a({1,2,3,4,5,6}, 2,3);
    Matrix<int> c = a.scalar_multiply(2);
    
    EXPECT_EQ(c(0,0), 2);
    EXPECT_EQ(c(0,1), 4);
    EXPECT_EQ(c(0,2), 6);
    EXPECT_EQ(c(1,0), 8);
    EXPECT_EQ(c(1,1), 10);
    EXPECT_EQ(c(1,2), 12);
}

TEST(Matrix, MatrixConstructor){
    EXPECT_THROW(Matrix<int> a({1,2,3,4,5}, 2, 3), std::invalid_argument);
}