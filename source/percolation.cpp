#include "percolation.h"
#include <vector>

bool hasPercolationCluster(const std::vector<std::vector<int>>& matriz){
    int L = matriz.size();
    std::vector<std::vector<bool>> visitado(L,std::vector<bool>(L,false));
    bool percola = false;
     for (int j = 0; j < L; ++j) {
        if (matriz[0][j] == 1 && !visitado[0][j]) {
            bool llegoAlFondo = false;
            dfs(matriz, visitado, 0, j, llegoAlFondo);
            if (llegoAlFondo) {
                percola = true;
                break;
            }
        }
    }
    return percola;
}

void dfs(const std::vector<std::vector<int>>& matriz, std::vector<std::vector<bool>>& visitado, int i, int j, bool& llegoAlFondo) {
    int L = matriz.size();
    if (i < 0 || i >= L || j < 0 || j >= L) return;
    if (matriz[i][j] == 0 || visitado[i][j]) return;

    visitado[i][j] = true;

    if (i == L - 1) llegoAlFondo = true;

    dfs(matriz, visitado, i + 1, j, llegoAlFondo); // abajo
    dfs(matriz, visitado, i - 1, j, llegoAlFondo); // arriba
    dfs(matriz, visitado, i, j + 1, llegoAlFondo); // derecha
    dfs(matriz, visitado, i, j - 1, llegoAlFondo); // izquierda
}

