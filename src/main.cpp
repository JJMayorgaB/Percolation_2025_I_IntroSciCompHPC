#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"

int main(int argc, char **argv) {

    if (argc < 3) {

        std::cerr << "Use: " << argv[0] << " <size_L> <p_val> <seed>(optional)\n";
        return 1;

    }

    int L = std::atoi(argv[1]);
    double p = std::atof(argv[2]);
    int seed = (argc == 4) ? std::atoi(argv[3]) : -1;

    // Validar parámetros de entrada
    if (L <= 0 || p < 0.0 || p > 1.0 || (argc >= 5 && seed <= 0)) {
        std::cerr << "Error: Invalid parameters\n";
        std::cerr << "L must be > 0, p must be between 0 and 1, seed (if given) must be > 0\n";
        return 1;
    }
        

    std::vector<int> matrix = generatematrix(L, p, seed);

    std::cout << "\nMatriz generada:\n";
    printmatrix(matrix, L);

    ClusterInfo info = hoshen_kopelman(matrix, L);

    std::cout << "\n¿Existe percolación?: " << (info.percolates ? "Si" : "No") << '\n';

    if (info.percolates) {
        std::cout << "Tamaño del mayor cluster percolante: " << info.max_cluster_size << '\n';
    } else {
        std::cout << "No hay cluster percolante, por lo tanto no se calcula el tamaño.\n";
    }
    print_clusters(info.labels,L);
    return 0;
}