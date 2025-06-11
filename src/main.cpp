#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"

int main(int argc, char **argv) {

    if (argc < 3) {
        std::cerr << "Uso: " << argv[0] << " <L> <p> [<seed>]\n"
                  << "Donde:\n"
                  << "  L    : Tamaño de la red (entero positivo)\n"
                  << "  p    : Probabilidad de ocupación (0.0 a 1.0)\n"
                  << "  seed : Semilla para RNG (opcional, -1 si no se especifica)\n";
        return 1;
    }

    int L = std::atoi(argv[1]);
    double p = std::atof(argv[2]);
    int seed = -1;
    if (argc == 4) {
        seed = std::atoi(argv[3]);
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