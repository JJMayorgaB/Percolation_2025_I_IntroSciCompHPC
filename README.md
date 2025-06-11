Percolation 2025 - Introduction to Scientific Computing and HPC
Este proyecto implementa simulaciones de percolación utilizando el algoritmo Hoshen-Kopelman con estructura de datos Union-Find para el análisis eficiente de clusters en redes bidimensionales.
📋 Descripción
La percolación es un fenómeno crítico que estudia la formación de caminos conectados en medios aleatorios. Este proyecto implementa:

Simulaciones de percolación en grillas 2D de diferentes tamaños
Algoritmo Hoshen-Kopelman para identificación eficiente de clusters
Análisis estadístico del umbral de percolación crítico
Visualizaciones de matrices de percolación y distribuciones de clusters
Profiling y optimización del código para HPC

🏗️ Estructura del Proyecto
├── src/                    # Código fuente principal
│   ├── main.cpp           # Programa principal de simulación
│   ├── time_main.cpp      # Programa para medición de tiempos
│   ├── matrix.cpp         # Implementación de matriz
│   ├── hoshen_kopelman.cpp # Algoritmo de clustering
│   ├── union_find.cpp     # Estructura de datos Union-Find
│   ├── test.cpp           # Tests unitarios con Catch2
│   ├── report.tex/.bib    # Documentación LaTeX
│   └── script.sh          # Script para simulaciones masivas
├── include/               # Headers
│   ├── matrix.h
│   ├── hoshen_kopelman.h
│   ├── union_find.h
│   ├── probvalues.h
│   └── catch2/            # Framework de testing
├── figures/               # Visualizaciones y análisis
│   ├── visualization.cpp
│   ├── clustervisualization.cpp
│   ├── visualize.py
│   ├── clustervisualize.py
│   ├── figures.py
│   └── time_figure.py
└── profiling/             # Resultados de profiling
🚀 Compilación y Uso
Requisitos Previos

Compilador: g++ con soporte C++17
Python 3 con matplotlib y numpy
Herramientas opcionales: gdb, valgrind, perf, gprof
Sistema: Linux/Unix (para profiling avanzado)

Comandos Principales
bash# Simulación rápida (L=4, p=0.6, seed=10)
make simul

# Ejecutar tests unitarios
make test

# Generar reporte completo en PDF
make report

# Simulación completa y generación de datos
make run-simulation

# Generar todas las figuras
make figures

# Ver ayuda completa
make help
Targets de Desarrollo
bash# Debug con GDB
make debug

# Análisis de memoria con Valgrind  
make valgrind

# Profiling completo (gprof + flamegraph)
make profile

# Limpiar archivos temporales
make clean
📊 Funcionalidades
Simulación Principal

Tamaños de grilla: 32×32 hasta 512×512
Rango de probabilidades: Enfoque en región crítica (~0.59)
Múltiples seeds para análisis estadístico robusto
Métricas: Probabilidad de percolación y tamaño del cluster más grande

Análisis de Performance

Medición de tiempos con diferentes niveles de optimización (-O1, -O3)
Profiling detallado con gprof y flamegraphs
Análisis de memoria con Valgrind y AddressSanitizer
Paralelización con GNU Parallel para experimentos masivos

Visualización

Matrices de percolación con diferentes probabilidades
Distribuciones de clusters en múltiples escalas
Gráficas de análisis de umbral crítico por tamaño
Análisis temporal y scaling de performance

🧪 Testing
El proyecto incluye tests unitarios con Catch2:
bash# Ejecutar todos los tests
make test

# Ejecutar tests específicos con filtro
make test FILTER="[tag]"
Los tests cubren:

Funcionalidad de matriz y Union-Find
Correctness del algoritmo Hoshen-Kopelman
Casos edge y validación de resultados

📈 Resultados y Análisis
Archivos Generados

build/graficas/: Datos de simulación para diferentes L y métricas
figures/: Visualizaciones PNG de matrices y análisis
profiling/: Reportes de performance y flamegraphs
time-*.txt: Mediciones temporales detalladas

Métricas Clave

Umbral crítico: pc ≈ 0.59271 para percolación 2D
Scaling temporal: Análisis de complejidad algoritmica
Distribución de clusters: Caracterización estadística

🔧 Configuración Avanzada
Flags de Compilación

Sanitizers: AddressSanitizer, UBSan, LeakSanitizer
Coverage: Instrumentación para análisis de cobertura
Optimización: Niveles -O0 hasta -O3 según target
Debug: Símbolos completos para debugging

Herramientas Externas

FlameGraph: Visualización de profiling (~/Downloads/FlameGraph)
GNU Parallel: Paralelización de experimentos
perf: Profiling avanzado del sistema

📖 Documentación
La documentación completa está disponible en LaTeX:
bashmake report  # Genera report.pdf
El reporte incluye:

Fundamentos teóricos de percolación
Descripción detallada de algoritmos
Análisis de resultados y performance
Referencias bibliográficas

🤝 Contribución
Este es un proyecto académico para el curso de Introducción a Computación Científica y HPC. La estructura está optimizada para:

Reproducibilidad de experimentos
Escalabilidad en sistemas HPC
Análisis riguroso de performance
Documentación completa de métodos y resultados

📄 Licencia
Proyecto académico - Universidad Nacional de Colombia
Introducción a Computación Científica y HPC - 2025-I
