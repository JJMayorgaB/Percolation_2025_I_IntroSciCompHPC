#ifndef UNION_FIND_H
#define UNION_FIND_H

#include <vector>

class UnionFind {
public:
    UnionFind(int size);
    int find(int x);
    void unite(int x, int y);
private:
    std::vector<int> parent;
};

#endif