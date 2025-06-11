#include "../include/hoshen_kopelman.h"
#include "../include/union_find.h"
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <iostream>
#include <iomanip>

ClusterInfo hoshen_kopelman(const std::vector<int>& matrix, int L) {
    int N = L * L;
    std::vector<int> labels(N, 0);  // 0: vacío
    UnionFind uf(N+1);
    int next_label = 1;

    // Paso 1: etiquetado preliminar con vecinos N y O
    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {
            int id = i * L + j;
            if (matrix[id] == 0) continue;

            int up = (i > 0 && matrix[(i - 1) * L + j] == 1) ? labels[(i - 1) * L + j] : 0;
            int left = (j > 0 && matrix[i * L + (j - 1)] == 1) ? labels[i * L + (j - 1)] : 0;

            if (up == 0 && left == 0) {
                labels[id] = next_label++;
            } else if (up != 0 && left == 0) {
                labels[id] = up;
            } else if (up == 0 && left != 0) {
                labels[id] = left;
            } else {
                labels[id] = std::min(up, left);
                uf.unite(up, left);
            }
        }
    }

    // OPTIMIZACIÓN 1: Reservar capacidad para hash maps
    std::unordered_map<int, int> root_to_compact;
    std::unordered_map<int, int> cluster_sizes;
    
    // Estimar número de clusters (típicamente mucho menor que N)
    int estimated_clusters = std::min(next_label, N/4);
    root_to_compact.reserve(estimated_clusters);
    cluster_sizes.reserve(estimated_clusters);
    
    int compact_label = 1;

    // OPTIMIZACIÓN 2: Usar emplace en lugar de operator[] y find
    for (int i = 0; i < N; ++i) {
        if (labels[i] == 0) continue;
        int root = uf.find(labels[i]);

        // Usar emplace para evitar doble lookup
        auto [it, inserted] = root_to_compact.emplace(root, compact_label);
        if (inserted) {
            compact_label++;
        }

        int label = it->second;
        labels[i] = label;
        
        // Incrementar cluster size directamente
        cluster_sizes[label]++;
    }

    // OPTIMIZACIÓN 3: Reservar capacidad para sets y usar vectores para bordes
    std::vector<int> top_labels, bottom_labels, left_labels, right_labels;
    top_labels.reserve(L);
    bottom_labels.reserve(L);
    left_labels.reserve(L);
    right_labels.reserve(L);

    // Recopilar labels de bordes
    for (int i = 0; i < L; ++i) {
        if (labels[i] > 0) top_labels.push_back(labels[i]);
        if (labels[(L - 1) * L + i] > 0) bottom_labels.push_back(labels[(L - 1) * L + i]);
        if (labels[i * L] > 0) left_labels.push_back(labels[i * L]);
        if (labels[i * L + (L - 1)] > 0) right_labels.push_back(labels[i * L + (L - 1)]);
    }

    // OPTIMIZACIÓN 4: Usar sets solo cuando sea necesario
    std::unordered_set<int> percolating_labels;
    
    // Ordenar para hacer intersección más eficiente
    std::sort(top_labels.begin(), top_labels.end());
    std::sort(bottom_labels.begin(), bottom_labels.end());
    std::sort(left_labels.begin(), left_labels.end());
    std::sort(right_labels.begin(), right_labels.end());

    // Intersección vertical (top ∩ bottom)
    auto it1 = top_labels.begin();
    auto it2 = bottom_labels.begin();
    while (it1 != top_labels.end() && it2 != bottom_labels.end()) {
        if (*it1 == *it2) {
            percolating_labels.insert(*it1);
            ++it1; ++it2;
        } else if (*it1 < *it2) {
            ++it1;
        } else {
            ++it2;
        }
    }

    // Intersección horizontal (left ∩ right)
    it1 = left_labels.begin();
    it2 = right_labels.begin();
    while (it1 != left_labels.end() && it2 != right_labels.end()) {
        if (*it1 == *it2) {
            percolating_labels.insert(*it1);
            ++it1; ++it2;
        } else if (*it1 < *it2) {
            ++it1;
        } else {
            ++it2;
        }
    }

    bool percolates = !percolating_labels.empty();
    int max_cluster_size = 0;
    for (int lbl : percolating_labels) {
        max_cluster_size = std::max(max_cluster_size, cluster_sizes[lbl]);
    }

    return {
        cluster_sizes,
        percolates,
        max_cluster_size,
        labels
    };
    
}

void print_clusters(const std::vector<int>& labels, int L) {
    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {
            int id = i * L + j;
            std::cout << std::setw(3) << labels[id] << " ";
        }
        std::cout << "\n";
    }
}