#include "../include/matrix.h"

//Generate the matrix
std::vector<int> generatematrix(int L, double p, int seed) {

    std::mt19937 gen;
    
    if (seed == -1) {
        std::random_device rd;
        gen.seed(rd()); // Semilla aleatoria
    } else {
        gen.seed(seed); // Semilla fija
    }

    std::uniform_real_distribution<> dis(0.0, 1.0);  

    int N = L * L;
    std::vector<int> matrix(N, 0);  // Vector 1D contiguo


    for (int i = 0; i < L; ++i) {

        for (int j = 0; j < L; ++j) {

            int id = i * L + j;  // Map 2D → 1D
            double r = dis(gen);
            matrix[id] = (r < p) ? 1 : 0; //Fills the matrix

        }
    }

    return matrix;
}


//Print the percolation matrix
void printmatrix(const std::vector<int>& matrix, int L) { 

    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {

            int id = i * L + j;  // Map 2D → 1D
            std::cout << (matrix[id] ? "1" : "0") << " ";

        }

        std::cout << '\n';
    }
}