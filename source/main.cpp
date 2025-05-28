#include "matriz.h"
#include "percolation.h"
#include <iostream>

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Uso: " << argv[0] << " <tamano_L> <probabilidad_p>\n";
        return 1;
    }

    int L = std::stoi(argv[1]);
    double p = std::stod(argv[2]);

    if (L <= 0 || p < 0.0 || p > 1.0) {
        std::cerr << "Error: L debe ser > 0 y p debe estar en [0, 1]\n";
        return 1;
    }

    auto matriz = generarMatriz(L, p);
    imprimirMatriz(matriz);

    if (hasPercolationCluster(matriz)) {
        std::cout << "¡Existe un cluster percolante!\n";
    } else {
        std::cout << "No hay cluster percolante.\n";
    }

    return 0;
}

