#include <vector>
#include <stdexcept>


template <typename T>
class Matrix{

    //add constructor
    std::vector<T> matrices_; //row major order
    std::size_t rows_;
    std::size_t columns_;

    public:

    Matrix(std::vector<T> input, std::size_t rows,  std::size_t columns){//need rows and colomn info for operations 
        matrices_ = input;
        rows_ = rows;
        columns_ = columns;
    }

    std::size_t size(Matrix A){
        return A.matrices_.size();
    }

    void scalar_multiply(int r){ // make it only apply to certain rows and default to whole thing
        for(std::size_t i=0; i< matrices_.size(); i++){
            matrices_[i] = matrices_[i]*r;
        }
        return;
    }

    Matrix matrix_addition(Matrix A, Matrix B){
        Matrix C;
        if(A.columns_ != B.columns_){
            throw std::invalid_argument("These matrixes don't have the same dimensions")
        }
         if(A.rows_ != B.rows_){
            throw std::invalid_argument("These matrixes don't have the same dimensions")
        }
        
        for(std::size_t i=0; i<A.size(); i++){
            C.matrices_.push_back(A.matrices_[i] + B.matrices_[i]);
        }
        return C;
    }

};