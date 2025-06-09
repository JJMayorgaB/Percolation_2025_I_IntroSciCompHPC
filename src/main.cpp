#include <iostream>
#include <vector>
#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"

int main() {
    int L;
    double p;

    std::cout << "Ingrese el tamaño de la matriz (LxL): ";
    std::cin >> L;
    std::cout << "Ingrese la probabilidad de ocupación (0.0 - 1.0): ";
    std::cin >> p;

    std::vector<int> matrix = generatematrix(L, p);

    std::cout << "\nMatriz generada:\n";
    printmatrix(matrix, L);

    ClusterInfo info = hoshen_kopelman(matrix, L);

    std::cout << "\n¿Existe percolación?: " << (info.percolates ? "Sí" : "No") << '\n';

    if (info.percolates) {
        std::cout << "Tamaño del mayor cluster percolante: " << info.max_cluster_size << '\n';
    } else {
        std::cout << "No hay cluster percolante, por lo tanto no se calcula el tamaño.\n";
    }
    print_clusters(info.labels,L);
    return 0;
}
