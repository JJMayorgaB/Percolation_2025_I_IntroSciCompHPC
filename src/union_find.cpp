#include "union_find.h"

UnionFind::UnionFind(int size) {
    parent.resize(size);
    for (int i = 0; i < size; ++i)
        parent[i] = i;
}

int UnionFind::find(int x) {
    if (parent[x] != x)
        parent[x] = find(parent[x]);
    return parent[x];
}

void UnionFind::unite(int x, int y) {
    int rx = find(x);
    int ry = find(y);
    if (rx != ry)
        parent[ry] = rx;
}