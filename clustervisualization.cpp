#include "matrix.h"
#include "dfspercolation.h"
#include "hoshen_kopelman.h"
/*
Este programa cumple el objetivo de devolvernos la matriz de percolación llenada por medio de la salida de 
la consola, una vez ejecutado este codigo se puede utilizar la salida en un .txt para obtener la grafica de la matriz.
*/

int main(int argc, char **argv) {

    if (argc != 3) {

        std::cerr << "Use: " << argv[0] << " <size_L> <probability_p>\n";
        return 1;

    }

    int L = std::atoi(argv[1]);
    double p = std::atof(argv[2]);

    if (L <= 0 || p < 0.0 || p > 1.0) {

        std::cerr << "Error: L should be > 0 and p should be in [0, 1]\n";
        return 1;

    }

    std::vector<int> matrix = generatematrix(L, p);

    auto result = hoshen_kopelman(matrix, L);

    print_clusters(result.labels, L);

    if (hasPercolationCluster(matrix, L)) {

        std::cout << "There is a percolating cluster\n";

    } else {

        std::cout << "There is no a percolating cluster\n";

    }


    std::cout << "Tamano maximo de cluster: " << result.max_cluster_size << "\n";


    return 0;
}

