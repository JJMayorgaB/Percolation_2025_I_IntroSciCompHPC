#include "percolation.h"


// Función principal de percolación
bool hasPercolationCluster(const std::vector<int>& matrix, int L) {

    std::vector<bool> visited(L * L, false);
    bool percolates = false;

    // Solo necesitamos verificar la fila superior (i = 0)
    for (int j = 0; j < L; ++j) {

        int id = 0 * L + j;  // Convertir (0,j) a índice 1D

        if (matrix[id] == 1 && !visited[id]) {

            bool reached_bottom = false;
            dfs(matrix, visited, L, 0, j, reached_bottom);

            if (reached_bottom) {

                percolates = true;
                break;

            }
        }
    }

    return percolates;
}

// Implementación DFS para matriz 1D
void dfs(const std::vector<int> & matrix, std::vector<bool> & visited, int L, int i, int j, bool& reached_bottom) {

    int id = i * L + j;
    
    // Verificar límites
    if (i < 0 || i >= L || j < 0 || j >= L) return;
    
    // Verificar si es sitio bloqueado o ya visitado
    if (matrix[id] == 0 || visited[id]) return;
    
    // Marcar como visitado
    visited[id] = true;
    
    // Verificar si llegamos al fondo
    if (i == L - 1) reached_bottom = true;
    
    // Explorar vecinos (arriba, abajo, izquierda, derecha)
    dfs(matrix, visited, L, i + 1, j, reached_bottom);  // Abajo
    dfs(matrix, visited, L, i - 1, j, reached_bottom);  // Arriba
    dfs(matrix, visited, L, i, j + 1, reached_bottom);  // Derecha
    dfs(matrix, visited, L, i, j - 1, reached_bottom);  // Izquierda
}




