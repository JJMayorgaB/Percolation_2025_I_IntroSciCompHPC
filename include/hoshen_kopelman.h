#ifndef HOSHEN_KOPELMAN_H
#define HOSHEN_KOPELMAN_H

#include <vector>
#include <unordered_map>

struct ClusterInfo {
    std::unordered_map<int, int> cluster_sizes;
    bool percolates;
    int max_cluster_size;
    std::vector<int> labels; // Etiquetas compactas
};

ClusterInfo hoshen_kopelman(const std::vector<int>& matrix, int L);
void print_clusters(const std::vector<int>& labels, int L);
#endif