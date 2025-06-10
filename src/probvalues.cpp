#include <vector>
#include <random>
#include <algorithm>
#include <iostream>
#include <cmath> // Para std::abs

// Función auxiliar para verificar si un valor ya está en el vector con cierta tolerancia
bool is_duplicate(const std::vector<double>& vec, double value, double tolerance = 1e-6) {
    for (double existing_val : vec) {
        if (std::abs(existing_val - value) < tolerance) {
            return true; // Se considera duplicado
        }
    }
    return false;
}

std::vector<double> generate_p_values(int N) {
    std::vector<double> p_values;
    
    // Validar entrada
    if (N < 10) {
        std::cerr << "Warning: N must be at least 10. Setting N to 10." << std::endl;
        N = 10;
    }
    
    // Valores fijos (siempre incluidos)
    std::vector<double> fixed_values = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.55, 0.6, 0.65, 0.7, 0.8, 0.9, 1.0};
    p_values.insert(p_values.end(), fixed_values.begin(), fixed_values.end());
    
    // Generador de números aleatorios
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);
    std::uniform_real_distribution<> dis_subrange(0.55, 0.65);
    
    // Generar valores aleatorios únicos (sin duplicados)
    while (p_values.size() < static_cast<size_t>(N)) {
        double new_val = dis(gen);
        if (!is_duplicate(p_values, new_val)) {
            p_values.push_back(new_val);
        }
    }
    
    // Asegurar que haya al menos 10 valores en [0.55, 0.65]
    size_t count_in_subrange = std::count_if(p_values.begin(), p_values.end(),
        [](double val) { return val >= 0.55 && val <= 0.65; });
    
    while (count_in_subrange < 10) {
        double new_val = dis_subrange(gen);
        if (!is_duplicate(p_values, new_val)) {
            p_values.push_back(new_val);
            count_in_subrange++;
        }
    }
    
    // Ordenar y eliminar duplicados (por si acaso)
    std::sort(p_values.begin(), p_values.end());
    
    // Eliminar duplicados con tolerancia (opcional, pero recomendado)
    auto last = std::unique(p_values.begin(), p_values.end(),
        [](double a, double b) { return std::abs(a - b) < 1e-6; });
    p_values.erase(last, p_values.end());
    
    return p_values;
}