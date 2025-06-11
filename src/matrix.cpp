#include "../include/matrix.h"

FastRandom::FastRandom(int seed) : dis(0.0, 1.0) {
    if (seed == -1) {
        std::random_device rd;
        gen.seed(rd());
    } else {
        gen.seed(seed);
    }
}

// Implementación de fill_vector
void FastRandom::fill_vector(std::vector<double>& vec) {
    for (auto& val : vec) {
        val = dis(gen);
    }
}

// Implementación de next()
inline double FastRandom::next() {
    return dis(gen);
}

//Generate the matrix
std::vector<int> generatematrix(int L, double p, int seed) {

    int N = L * L;
    std::vector<int> matrix(N);
    
    FastRandom rng(seed);
    
    // Generar todos los números aleatorios de una vez
    std::vector<double> random_values(N);
    rng.fill_vector(random_values);
    
    // Convertir a matriz binaria
    for (int i = 0; i < N; ++i) {
        matrix[i] = (random_values[i] < p) ? 1 : 0;
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