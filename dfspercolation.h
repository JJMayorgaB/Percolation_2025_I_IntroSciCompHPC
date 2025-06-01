#include <vector>

bool hasPercolationCluster(const std::vector<int>& matrix, int L);
void dfs(const std::vector<int> & matrix, std::vector<bool> & visited, int L, int i, int j, bool& reached_bottom);
