#include "../include/probvalues.h"

std::vector<double> generate_p_values(int N) {
    
    std::vector<double> p_values;
    
    // Validate input
    if (N < 10) {
        std::cerr << "Warning: N must be at least 10. Setting N to 10." << std::endl;
        N = 10;
    }
    
    // Fixed values that should always be included
    std::vector<double> fixed_values = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.55, 0.6, 0.65, 0.7, 0.8, 0.9, 1.0};
    
    // Add the fixed values
    p_values.insert(p_values.end(), fixed_values.begin(), fixed_values.end());
    
    // Random number generation setup
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);
    std::uniform_real_distribution<> dis_subrange(0.55, 0.65);
    
    // Ensure we have at least N values total
    while (p_values.size() < static_cast<size_t>(N)) {
        p_values.push_back(dis(gen));
    }
    
    // Count how many values are currently in [0.55, 0.65]
    size_t count_in_subrange = std::count_if(p_values.begin(), p_values.end(), 
        [](double val) { return val >= 0.55 && val <= 0.65; });
    
    // Add more values to ensure exactly 10 in [0.55, 0.65]
    while (count_in_subrange < 10) {
        p_values.push_back(dis_subrange(gen));
        count_in_subrange++;
    }
    
    // Sort the vector
    std::sort(p_values.begin(), p_values.end());
    
    // Remove duplicates (if any)
    p_values.erase(std::unique(p_values.begin(), p_values.end()), p_values.end());
    
    return p_values;
}