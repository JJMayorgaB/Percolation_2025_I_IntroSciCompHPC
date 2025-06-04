#include "hoshen_kopelman.h"
#include "union_find.h"
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <iostream>
#include <iomanip>

ClusterInfo hoshen_kopelman(const std::vector<int>& matrix, int L) {
    int N = L * L;
    std::vector<int> labels(N, 0);  // 0: vacío
    UnionFind uf(N);
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

    // Paso 2: compactar etiquetas usando las raíces
    std::unordered_map<int, int> root_to_compact;
    std::unordered_map<int, int> cluster_sizes;
    int compact_label = 1;

    for (int i = 0; i < N; ++i) {
        if (labels[i] == 0) continue;
        int root = uf.find(labels[i]);

        if (root_to_compact.find(root) == root_to_compact.end()) {
            root_to_compact[root] = compact_label++;
        }

        int label = root_to_compact[root];
        labels[i] = label;
        cluster_sizes[label]++;
    }

    // Paso 3: detectar percolación (de arriba a abajo)
    std::unordered_set<int> top, bottom;
    for (int j = 0; j < L; ++j) {
        if (labels[j] > 0)
            top.insert(labels[j]);
        if (labels[(L - 1) * L + j] > 0)
            bottom.insert(labels[(L - 1) * L + j]);
    }

    int percolating_label = -1;
    for (int lbl : top) {
        if (bottom.count(lbl)) {
            percolating_label = lbl;
            break;
        }
    }

    bool percolates = (percolating_label != -1);
    int max_cluster_size = percolates ? cluster_sizes[percolating_label] : 0;

    return {
        cluster_sizes,
        percolates,
        max_cluster_size,
        labels
    };

}
/*
void print_clusters(const std::vector<int>& labels, int L) {
    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {
            int id = i * L + j;
            if (labels[id] == 0) {
                std::cout << "0 ";
            } else {
                std::cout << (labels[id] % 10) << " ";
            }
        }
        std::cout << "\n";
    }
}
*/
void print_clusters(const std::vector<int>& labels, int L) {
    for (int i = 0; i < L; ++i) {
        for (int j = 0; j < L; ++j) {
            int id = i * L + j;
            std::cout << std::setw(3) << labels[id] << " ";
        }
        std::cout << "\n";
    }
}