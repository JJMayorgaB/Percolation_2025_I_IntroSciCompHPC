#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"

int main(int argc, char **argv) {
    
    int L;
    double p;
    int seed = -1; //semilla aleatoriaL * L

    // Si se pasan argumentos, úsalos; si no, pide entrada interactiva
    if (argc >= 3) {

        L = std::atoi(argv[1]);
        p = std::atof(argv[2]);
        if (argc == 4) {
            seed = std::atoi(argv[3]);
        }
        
    } else {

        std::cout << "Ingrese el tamano de la matriz (LxL): ";
        std::cin >> L;
        std::cout << "Ingrese la probabilidad de ocupacion (0.0 - 1.0): ";
        std::cin >> p;

    }

    std::vector<int> matrix = generatematrix(L, p, seed);

    std::cout << "\nMatriz generada:\n";
    printmatrix(matrix, L);

    ClusterInfo info = hoshen_kopelman(matrix, L);

    std::cout << "\nExiste percolacion?: " << (info.percolates ? "Si" : "No") << '\n';

    if (info.percolates) {
        std::cout << "Tamano del mayor cluster percolante: " << info.max_cluster_size << '\n';
    } else {
        std::cout << "No hay cluster percolante, por lo tanto no se calcula el tamano.\n";
    }
    print_clusters(info.labels,L);
    return 0;
} 