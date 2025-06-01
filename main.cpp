#include "matrix.h"
#include "dfspercolation.h"

int main(int argc, char **argv) {

    if (argc != 3) {

        std::cerr << "Uso: " << argv[0] << " <size_L> <probability_p>\n";
        return 1;

    }

    int L = std::atoi(argv[1]);
    double p = std::atof(argv[2]);

    if (L <= 0 || p < 0.0 || p > 1.0) {

        std::cerr << "Error: L debe ser > 0 y p debe estar en [0, 1]\n";
        return 1;

    }

    std::vector<int> matrix = generatematrix(L, p);
    printmatrix(matrix, L);

    if (hasPercolationCluster(matrix, L)) {

        std::cout << "¡Existe un cluster percolante!\n";

    } else {

        std::cout << "No hay cluster percolante.\n";

    }

    return 0;
}

