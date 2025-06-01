#include "matriz.h"
#include <random>
#include <iostream>

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
            std::cout << (celda ? "1" : "0");
        }
        std::cout << '\n';
    }
}