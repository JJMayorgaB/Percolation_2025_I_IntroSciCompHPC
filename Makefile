# Compilador y directorios
CXX = g++
INC_DIR = include
SRC_DIR = src

# Flags 
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
TIME_MAIN_SOURCES =  $(SRC_DIR)/time_main.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp
PRINTVALUES_SOURCES = $(SRC_DIR)/printvalues.cpp $(SRC_DIR)/probvalues.cpp

# Headers (ajusta según tus archivos)
HEADERS = $(wildcard $(INC_DIR)/*.h)

# Archivos de datos y figuras
DATA_FILES = build/graficas/L32_P.txt build/graficas/L64_P.txt build/graficas/L128_P.txt build/graficas/L256_P.txt build/graficas/L512_P.txt \
             build/graficas/L32_Cluster.txt build/graficas/L64_Cluster.txt build/graficas/L128_Cluster.txt build/graficas/L256_Cluster.txt build/graficas/L512_Cluster.txt
FIGURE_FILES = figures/P_all_L.png figures/Cluster_all_L.png figures/percolation.png figures/clusterpercolation.png
TIME_FILES = $(wildcard time-*-*.txt)

# Targets por defecto
.PHONY: all clean debug valgrind profile run-simulation figures report help clean-figures time-executables
.DEFAULT_GOAL := all

all: main.x printvalues.x

# Compilar main.x con sanitizers y coverage
main.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -O3 $(SANITIZE_FLAGS) $(COVERAGE_FLAGS) -o $@ $(MAIN_SOURCES)

# Niveles de optimización para time_main
OPTIMIZATION_LEVELS = 1 3
TIME_EXECUTABLES = $(foreach opt,$(OPTIMIZATION_LEVELS),time_mainO$(opt).x)

# Compilar time_main con diferentes niveles de optimización
time_mainO%.x: $(TIME_MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -O$* $(SANITIZE_FLAGS) -o $@ $(TIME_MAIN_SOURCES)

# Target para ejecutar los experimentos de tiempo
time-computing: $(TIME_EXECUTABLES) probabilidades10.txt
	parallel './time_mainO{1}.x {1} {2} {3} >> time-{1}-{3}.txt' ::: 1 3 ::: $$(cat probabilidades10.txt) ::: {100..1000..100}

# Target para compilar solo los ejecutables de tiempo
time-executables: $(TIME_EXECUTABLES)

# Compilar printvalues.x
printvalues.x: $(PRINTVALUES_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(SANITIZE_FLAGS) $(COVERAGE_FLAGS) -o $@ $(PRINTVALUES_SOURCES)

# Generar archivo de probabilidades
probabilidades%.txt: printvalues.x
	./printvalues.x $* > $@

# Ejecutar simulación (solo genera datos, NO figuras)
run-simulation: main.x printvalues.x probabilidades50.txt
	@echo "Ejecutando simulación..."
	@bash $(SRC_DIR)/script.sh
	@echo "Simulación completada. Datos generados en build/graficas/"

# Archivos fuente para visualización
VISUALIZATION_SOURCES = figures/visualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp
CLUSTERVIS_SOURCES = figures/clustervisualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp

# Compilar programa de visualización
figures/visualization.x: $(VISUALIZATION_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(VISUALIZATION_SOURCES)

# Compilar programa de visualización de clusters
figures/clustervisualization.x: $(CLUSTERVIS_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(CLUSTERVIS_SOURCES)

# Regla para generar los archivos de datos individualmente
$(DATA_FILES): 
	@echo "Los archivos de datos no existen. Ejecutando simulación..."
	@$(MAKE) run-simulation

# Generar figuras (depende de datos y programas de visualización)
$(FIGURE_FILES): figures/visualization.x figures/clustervisualization.x | $(DATA_FILES) | $(TIME_FILES)
	@echo "Generando figuras..."
	./figures/visualization.x 10 0.5 0.6 > figures/data.txt
	python3 ./figures/visualize.py
	./figures/clustervisualization.x 10 0.5 0.6 > figures/data_clusters.txt
	python3 ./figures/clustervisualize.py
	python3 ./figures/figures.py
	@echo "Figuras generadas exitosamente"

# Target para generar figuras manualmente
figures: $(FIGURE_FILES)

report: report.pdf

report.pdf: src/report.tex src/report.bib
	@mkdir -p latex_output
	@echo "Compilando reporte LaTeX..."
	# Primera compilación
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=latex_output src/report.tex
	# Procesar bibliografía si existe
	@if [ -f src/report1.bib ]; then \
		cp src/report1.bib latex_output/; \
		cd latex_output && bibtex report && cd ..; \
		echo "Bibliografía procesada"; \
	else \
		echo "Advertencia: No se encontró archivo .bib"; \
	fi
	# Segunda compilación para resolver referencias
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=latex_output src/report.tex
	# Tercera compilación para asegurar referencias cruzadas
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=latex_output src/report.tex
	# Copiar PDF final al directorio raíz
	cp latex_output/report.pdf report.pdf
	@echo "Reporte generado exitosamente: report.pdf"

# Simulación rápida
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
	$(CXX) $(CXXFLAGS) $(PROFILE_FLAGS) -o $@ $(MAIN_SOURCES)

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
	rm -rf build latex_output profiling
	rm -f src/*.x
	
# Limpiar solo figuras (útil para forzar regeneración)
clean-figures:
	rm -f $(FIGURE_FILES) figures/data.txt figures/data_clusters.txt

help:
	@echo "Targets disponibles:"
	@echo "  all            - Compilar main.x y printvalues.x"
	@echo "  run-simulation - Ejecutar simulación y generar datos"
	@echo "  figures        - Generar figuras (solo si no existen)"
	@echo "  report         - Generar reporte PDF"
	@echo "  clean-figures  - Limpiar solo las figuras"
	@echo "  debug          - Compilar y ejecutar con GDB"
	@echo "  valgrind       - Análisis de memoria con Valgrind"
	@echo "  profile        - Profiling completo con gprof y flamegraph"
	@echo "  clean          - Limpiar archivos generados"
	@echo "  simul          - Compilación y simulación con L=4, p=0.6 y seed=10"
	@echo "  help           - Mostrar esta ayuda"