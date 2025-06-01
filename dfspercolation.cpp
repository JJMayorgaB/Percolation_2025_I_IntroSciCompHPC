#include "dfspercolation.h"

// Función principal de percolación
bool hasPercolationCluster(const std::vector<int>& matrix, int L) {

    std::vector<bool> visited(L * L, false);
    
    for (int j = 0; j < L; ++j) {
        int id = j;  // (0,j) since i=0
        
        if (matrix[id] == 1 && !visited[id]) {
            bool reached_bottom = false;
            dfs(matrix, visited, L, 0, j, reached_bottom);
            
            if (reached_bottom) {
                return true;  // Salir inmediatamente al encontrar percolación
            }
        }
    }
    
    return false;
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
    dfs(matrix, visited, L, i + 1, j, reached_bottom);  // Abajo primero
    if (!reached_bottom) dfs(matrix, visited, L, i - 1, j, reached_bottom);
    if (!reached_bottom) dfs(matrix, visited, L, i, j + 1, reached_bottom);
    if (!reached_bottom) dfs(matrix, visited, L, i, j - 1, reached_bottom);
}




