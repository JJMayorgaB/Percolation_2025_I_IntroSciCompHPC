#include "../include/matrix.h"
#include "../include/hoshen_kopelman.h"
#include <ctime>
#include <chrono>

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

    auto wstart{std::chrono::steady_clock::now()};   // Wall time
    std::clock_t cstart = std::clock();              // CPU time

    std::vector<int> matrix = generatematrix(L, p, seed);

    ClusterInfo info = hoshen_kopelman(matrix, L);

    auto wend{std::chrono::steady_clock::now()};
    std::clock_t cend = std::clock();

    std::chrono::duration<double> elapsed{wend - wstart};
    double wduration = elapsed.count();
    double cduration = cend - cstart;

     std::cout << L << "\t" << wduration << "\t" << cduration << "\n";

    return 0;
}