#include <vector>

bool hasPercolationCluster(const std::vector<std::vector<int>>& matriz);
void dfs(const std::vector<std::vector<int>>& matriz, std::vector<std::vector<bool>>& visitado, int i, int j, bool& llegoAlFondo);
