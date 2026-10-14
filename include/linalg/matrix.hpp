#include <vector>
#include <stdexcept>
#include <cassert>
#include <string>
#include <utility>


template <typename T>
class Matrix{

    //add constructor
    std::vector<T> matrices_; //row major order
    std::size_t rows_;
    std::size_t cols_;
    std::size_t size() const { return matrices_.size(); }

    public:

    Matrix(std::vector<T> input, std::size_t rows,  std::size_t columns){//need rows and colomn info for operations 
        matrices_ = input;
        rows_ = rows;
        cols_ = columns;
    }

    std::size_t rows() const{
        return rows_;
    }

    std::size_t cols() const{
        return cols_;
    }

    T& operator()(std::size_t r, std::size_t c) {
        assert(r < rows_ && c < cols_);
        return matrices_[r * cols_ + c];
    }

    const T& operator()(std::size_t r, std::size_t c) const {
        assert(r < rows_ && c < cols_);
        return matrices_[r * cols_ + c];
    }

    void scalar_multiply(int r){ // make it only apply to certain rows and default to whole thing
        for(std::size_t i=0; i< matrices_.size(); i++){
            matrices_[i] = matrices_[i]*r;
        }
        return;
    }

    Matrix operator+(const Matrix& other) const {
        if (rows_ != other.rows_ || cols_ != other.cols_) {
            throw std::invalid_argument(
                "cannot add " + std::to_string(rows_) + "x" + std::to_string(cols_) +
                " and " + std::to_string(other.rows_) + "x" + std::to_string(other.cols_));
        }

        std::vector<T> result(matrices_.size());
        for (std::size_t i = 0; i < matrices_.size(); i++) {
            result[i] = matrices_[i] + other.matrices_[i];
        }

        return Matrix(std::move(result), rows_, cols_);
    }

    Matrix operator-(const Matrix& other) const {
        if (rows_ != other.rows_ || cols_ != other.cols_) {
            throw std::invalid_argument(
                "cannot subtract " + std::to_string(rows_) + "x" + std::to_string(cols_) +
                " and " + std::to_string(other.rows_) + "x" + std::to_string(other.cols_));
        }

        std::vector<T> result(matrices_.size());
        for (std::size_t i = 0; i < matrices_.size(); i++) {
            result[i] = matrices_[i] - other.matrices_[i];
        }

        return Matrix(std::move(result), rows_, cols_);
    }

    Matrix transpose()const{
        std::vector<T> result;
        result.reserve(matrices_.size());
        for (std::size_t i = 0; i < cols_; i++) {      // rows of the result
            for (std::size_t j = 0; j < rows_; j++) {  // columns of the result
                result.push_back((*this)(j, i));
            }
        }
        return Matrix(result,cols_,rows_);
    }

    Matrix operator*(const Matrix& other) const{
        if (cols_ != other.rows_) {
            throw std::invalid_argument("cannot multiply " + std::to_string(rows_) + "x" + std::to_string(cols_) +
                                        " by " + std::to_string(other.rows_) + "x" + std::to_string(other.cols_));
        }
        std::vector<T> result;
        result.reserve(rows_ * other.cols_);
        for(std::size_t i = 0; i<rows_; i++){// i = Ar
            for(std::size_t j = 0; j<other.cols_; j++){// j = Bc
                T sum = 0;
                for(std::size_t k = 0; k<cols_; k++){//k = Ac & Br
                    sum += ((*this)(i,k) * other(k,j));
                }
                result.push_back(sum);
            }
        }
        return Matrix(std::move(result), rows_, other.cols_);
    }
};