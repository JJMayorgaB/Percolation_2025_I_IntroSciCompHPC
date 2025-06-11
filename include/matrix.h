#ifndef MATRIX_H
#define MATRIX_H

#include <vector>
#include <random>
#include <iostream>

class FastRandom {
private:
    std::mt19937 gen;
    std::uniform_real_distribution<double> dis;
    
public:
    FastRandom(int seed = -1);
    void fill_vector(std::vector<double>& vec);
    inline double next();
};

std::vector<int> generatematrix(int L, double p, int seed = -1);
void printmatrix(const std::vector<int>& matrix, int L);

#endif 

