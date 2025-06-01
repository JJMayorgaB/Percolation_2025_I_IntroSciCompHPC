#include "matrix.h"
#include "dfspercolation.h"
#include "probvalues.h"

/*
El objetivo de este programa es calcular la probabilidad de conseguir un cluster percolante
*/

int main(int argc, char **argv) {

    if (argc != 3) {

        std::cerr << "Use: " << argv[0] << " <size_L> <num_samples>\n";
        return 1;

    }

    int L = std::atoi(argv[1]);
    int num_samples = std::atof(argv[2]);


    // Array de valores de p específicos
    std::vector<double> p_values = generate_p_values(30);

    // Barrer los valores de p desde el array
    for (double p : p_values) {

        int percolating_count = 0;
        
        // Realizar múltiples muestras para estimar P(p, L)
        for (int i = 0; i < num_samples; ++i) {

            std::vector<int> matrix = generatematrix(L, p);

            if (hasPercolationCluster(matrix, L)) {
                percolating_count++;
            }

        }

        double probability = static_cast<double>(percolating_count) / num_samples;
        std::cout << L << "\t" << p << "\t" << probability << std::endl;
    }

    return 0;

}