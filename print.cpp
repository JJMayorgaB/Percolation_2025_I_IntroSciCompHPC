#include "probvalues.h"

/*
Este programa es de verificación, queremos ver la salida de generate_p_values(N), borrar despues
*/

int main(int argc, char **argv) {

    int N = std::atoi(argv[1]);
     
    std::vector<double> p_values = generate_p_values(N);

     std::cout << std::fixed << std::setprecision(2);
    
    for (size_t i = 0; i < p_values.size(); ++i) {

        std::cout << p_values[i] << "\n";
        
    }
    
    return 0;
}