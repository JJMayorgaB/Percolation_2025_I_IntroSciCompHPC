#include "probvalues.h"

/*
Este programa es de verificación, queremos ver la salida de generate_p_values(N), borrar despues
*/

int main(int argc, char **argv) {

    int N = std::atoi(argv[1]);
     
    std::vector<double> p_values = generate_p_values(N);
    
    // Print the generated values
    std::cout << "Generated " << p_values.size() << " values:" << std::endl;

    std::cout << std::fixed << std::setprecision(2);
    for (size_t i = 0; i < p_values.size(); ++i) {
        std::cout << p_values[i];
        if (i != p_values.size() - 1) std::cout << ", ";
        if ((i + 1) % 10 == 0) std::cout << std::endl;
    }
    std::cout << std::endl;
    
    // Count values in [0.55, 0.65] to verify
    int count = std::count_if(p_values.begin(), p_values.end(), 
        [](double val) { return val >= 0.55 && val <= 0.65; });
    std::cout << "Number of values in [0.55, 0.65]: " << count << std::endl;
    
    return 0;
}