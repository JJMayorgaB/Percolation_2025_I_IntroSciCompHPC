# Compilador y directorios
CXX = g++
INC_DIR = include
SRC_DIR = src

# Flags base
CXXFLAGS = -std=c++17 -I $(INC_DIR)
SANITIZE_FLAGS = -fsanitize=address,undefined,leak
COVERAGE_FLAGS = -fprofile-arcs -ftest-coverage
DEBUG_FLAGS = -g -ggdb -O0
VALGRIND_FLAGS = -g -O1
PROFILE_FLAGS = -O0 -pg -g -fno-inline

# Herramientas externas
FLAME = $(HOME)/Downloads/FlameGraph

# Archivos fuente
MAIN_SOURCES = $(SRC_DIR)/main.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp
PRINTVALUES_SOURCES = $(SRC_DIR)/printvalues.cpp $(SRC_DIR)/probvalues.cpp

# Headers (ajusta según tus archivos)
HEADERS = $(wildcard $(INC_DIR)/*.h)

# Targets por defecto
.PHONY: all clean debug valgrind profile run-simulation
.DEFAULT_GOAL := all

all: main.x printvalues.x

# Compilar main.x con sanitizers y coverage
main.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -O3 $(SANITIZE_FLAGS) $(COVERAGE_FLAGS) -o $@ $(MAIN_SOURCES)

# Compilar printvalues.x
printvalues.x: $(PRINTVALUES_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(SANITIZE_FLAGS) $(COVERAGE_FLAGS) -o $@ $(PRINTVALUES_SOURCES)

# Generar archivo de probabilidades
probabilidades.txt: printvalues.x
	./printvalues.x 50 > $@

#Ejecutar simulación
run-simulation: main.x printvalues.x probabilidades.txt
	@bash $(SRC_DIR)/script.sh

# Archivos fuente para visualización
VISUALIZATION_SOURCES = figures/visualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp
CLUSTERVIS_SOURCES = figures/clustervisualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp

# Compilar programa de visualización
figures/visualization.x: $(VISUALIZATION_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(VISUALIZATION_SOURCES)

# Compilar programa de visualización de clusters
figures/clustervisualization.x: $(CLUSTERVIS_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(CLUSTERVIS_SOURCES)

# Archivos de datos generados por run-simulation
DATA_FILES = build/graficas/L32_P.txt build/graficas/L64_P.txt build/graficas/L128_P.txt build/graficas/L256_P.txt build/graficas/L512_P.txt \
             build/graficas/L32_Cluster.txt build/graficas/L64_Cluster.txt build/graficas/L128_Cluster.txt build/graficas/L256_Cluster.txt build/graficas/L512_Cluster.txt


# Generar todas las figuras
figures: figures/visualization.x figures/clustervisualization.x $(DATA_FILES)
	./figures/visualization.x 10 0.5 0.6 > figures/data.txt
	python3 ./figures/visualize.py
	./figures/clustervisualization.x 10 0.5 0.6 > figures/data_clusters.txt
	python3 ./figures/clustervisualize.py
	python3 ./figures/figures.py

# Generar archivos de datos (ejecuta run-simulation si no existen)
$(DATA_FILES): run-simulation

# Generar reporte PDF desde LaTeX (requiere figuras)
report: figures report.pdf

report.pdf: src/report.tex figures
	@mkdir -p latex_output
	pdflatex -output-directory=latex_output src/report.tex

	pdflatex -output-directory=latex_output src/report.tex

	@if grep -q "\\bibliography" src/report.tex; then \
		cd latex_output && bibtex report.aux; \
		cd .. && pdflatex -output-directory=latex_output src/report.tex; \
	fi
	@# Copiar PDF final al directorio raíz
	cp latex_output/report.pdf .
	@echo "Reporte generado: report.pdf"

#Simulación
simul: main.x
	./main.x 4 0.6 10 

# Debug con GDB
debug: main_debug.x
	gdb ./main_debug.x

main_debug.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $@ $(MAIN_SOURCES)

# Análisis con Valgrind
valgrind: main_val.x
	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes ./main_val.x 6 0.6 10

main_val.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(VALGRIND_FLAGS) -o $@ $(MAIN_SOURCES)

# Profiling con gprof
main_pg.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(PROFILE_FLAGS) -o $@ $(MAIN_SOURCES


profiling-report.txt: main_pg.x
	@mkdir -p profiling
	perf record -g --output=profiling/perf.data \
	            ./main_pg.x 128 0.59271 10
	perf report --stdio --input=profiling/perf.data > profiling/report.txt

profile: main_pg.x 
	@mkdir -p profiling
	./main_pg.x 8 0.5 10 
	gprof main_pg.x gmon.out | grep -v 'std::\|__gnu_cxx\|operator\|std::chrono\|std::__' > profiling/analysis.txt

	perf record --call-graph dwarf -F99 -g -- ./main_pg.x 8 0.5 10
	perf script | $(FLAME)/stackcollapse-perf.pl > profiling/out.folded
	$(FLAME)/flamegraph.pl profiling/out.folded > profiling/flamegraph.svg

	@echo "Wrote flat profile and flamegraph to profiling/analysis.txt and profiling/flamegraph.svg"


clean:
		rm -f *.x *.gcno *.gcda *.gcov *.data *.out *.txt gmon.out
	rm -f figures/*.x figures/data.txt figures/data_clusters.txt
	rm -rf build

help:
	@echo "Targets disponibles:"
	@echo "  all          - Compilar main.x y printvalues.x"
	@echo "  debug        - Compilar y ejecutar con GDB"
	@echo "  valgrind     - Análisis de memoria con Valgrind"
	@echo "  profile      - Profiling completo con gprof y flamegraph"
	@echo "  clean        - Limpiar archivos generados"
	@echo "  help         - Mostrar esta ayuda"
