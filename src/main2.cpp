#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"

/*
Funcion main alterna
*/

int main(int argc, char **argv) {

    if (argc < 4) {

        std::cerr << "Use: " << argv[0] << " <size_L> <num_samples> <p_vals> <seed>(optional)\n";
        return 1;

    }

    int L = std::atoi(argv[1]);
    int num_samples = std::atoi(argv[2]);
    double p = std::atof(argv[3]);
    int seed = (argc == 5) ? std::atoi(argv[4]) : -1;

    // Validar parámetros de entrada
    if (L <= 0 || num_samples <= 0 || p < 0.0 || p > 1.0 || (argc >= 5 && seed <= 0)) {
        std::cerr << "Error: Invalid parameters\n";
        std::cerr << "L must be > 0, num_samples must be > 0, p must be between 0 and 1, seed (if given) must be > 0\n";
        return 1;
    }

    int percolating_count = 0;
    int total_cluster_size = 0;
        
    // Realizar múltiples muestras para estimar P(p, L)
    for (int i = 0; i < num_samples; ++i) {

        std::vector<int> matrix = generatematrix(L, p, seed);
        ClusterInfo info = hoshen_kopelman(matrix, L);
       
        if (info.percolates) {  
                total_cluster_size += info.max_cluster_size;
                percolating_count++;
        }

    }

    double probability = static_cast<double>(percolating_count) / num_samples;

    // Calcular tamaño medio solo si hay clusters percolantes
    double mean_size = 0.0;
    if (percolating_count > 0) {
        mean_size = static_cast<double>(total_cluster_size) /(percolating_count*L*L); //Normalizado a L^2
    }

    std::cout << L << p << "\t" << probability << "\t" << mean_size << std::endl;

    return 0;

} 
