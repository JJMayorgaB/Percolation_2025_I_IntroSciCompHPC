#include <iostream>
#include <vector>
#include <random>
#include <iomanip> // opcional, por estética

// Función que genera la matriz
std::vector<std::vector<int>> generarMatriz(int L, double p) {
    std::vector<std::vector<int>> matriz(L, std::vector<int>(L, 0));

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);

    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {
            double r = dis(gen);
            matriz[i][j] = (r < p) ? 1 : 0;
        }
    }

    return matriz;
}

// Función para imprimir la matriz
void imprimirMatriz(const std::vector<std::vector<int>>& matriz) {
    for (const auto& fila : matriz) {
        for (int celda : fila) {
            std::cout << (celda ? "x" : " ");
        }
        std::cout << '\n';
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Uso: " << argv[0] << " <tamano_L> <probabilidad_p>\n";
        return 1;
    }

    int L = std::stoi(argv[1]);
    double p = std::stod(argv[2]);

    if (L <= 0 || p < 0.0 || p > 1.0) {
        std::cerr << "Error: L debe ser > 0 y p debe estar en [0, 1]\n";
        return 1;
    }

    auto matriz = generarMatriz(L, p);
    imprimirMatriz(matriz);

    return 0;
}