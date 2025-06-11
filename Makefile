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
TEST_SOURCES = $(SRC_DIR)/test.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp 
TEST_OBJECTS = $(TEST_SOURCES:.cpp=.o) 

# Headers 
HEADERS = $(wildcard $(INC_DIR)/*.h)

# Archivos de datos y figuras
DATA_FILES = build/graficas/L32_P.txt build/graficas/L64_P.txt build/graficas/L128_P.txt build/graficas/L256_P.txt build/graficas/L512_P.txt \
             build/graficas/L32_Cluster.txt build/graficas/L64_Cluster.txt build/graficas/L128_Cluster.txt build/graficas/L256_Cluster.txt build/graficas/L512_Cluster.txt
FIGURE_FILES = figures/P_all_L.png figures/Cluster_all_L.png figures/percolation1.png figures/clusterpercolation1.png figures/time_analysis.png \
			 figures/percolation2.png figures/clusterpercolation2.png figures/clusterpercolation3.png figures/clusterpercolation4.png
TIME_FILES = time-1-100.txt time-1-200.txt time-1-300.txt time-1-400.txt time-1-500.txt \
             time-1-600.txt time-1-700.txt time-1-800.txt time-1-900.txt time-1-1000.txt \
             time-1-1100.txt time-1-1200.txt time-1-1300.txt time-1-1400.txt time-1-1500.txt \
             time-1-1600.txt time-1-1700.txt time-1-1800.txt time-1-1900.txt time-1-2000.txt \
             time-3-100.txt time-3-200.txt time-3-300.txt time-3-400.txt time-3-500.txt \
             time-3-600.txt time-3-700.txt time-3-800.txt time-3-900.txt time-3-1000.txt \
             time-3-1100.txt time-3-1200.txt time-3-1300.txt time-3-1400.txt time-3-1500.txt \
             time-3-1600.txt time-3-1700.txt time-3-1800.txt time-3-1900.txt time-3-2000.txt

# Archivos fuente para visualización
VISUALIZATION_SOURCES = figures/visualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp
CLUSTERVIS_SOURCES = figures/clustervisualization.cpp $(SRC_DIR)/matrix.cpp $(SRC_DIR)/hoshen_kopelman.cpp $(SRC_DIR)/union_find.cpp

# Targets por defecto
.PHONY: simul test report profile debug valgrind clean profiling-report.txt run-simulation figures clean-figures check-figures help
.DEFAULT_GOAL := all

# Simulación rápida
simul: main.x
	./main.x 4 0.6 10 

#test con catch2
test: test.x
	./test.x $(FILTER)

#imprime el reporte en LaTex
report:	src/report.tex src/report.bib check-figures
	@mkdir -p latex_output
	@echo "Compilando reporte LaTeX..."
	# Primera compilación
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=latex_output src/report.tex
	# Procesar bibliografía si existe
	@if [ -f src/report.bib ]; then \
		cp src/report.bib latex_output/; \
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
	rm -rf latex_output
	@echo "Reporte generado exitosamente: report.pdf"

#profile
profile: main_pg.x 
	@mkdir -p profiling
	./main_pg.x 8 0.5 10 
	@#Profiling con gprof
	gprof main_pg.x gmon.out | grep -v 'std::\|__gnu_cxx\|operator\|std::chrono\|std::__' > profiling/analysis.txt
	@#Profiling con perf
	perf record --call-graph dwarf -F99 -g -- ./main_pg.x 8 0.5 10
	perf script | $(FLAME)/stackcollapse-perf.pl > profiling/out.folded
	$(FLAME)/flamegraph.pl profiling/out.folded > profiling/flamegraph.svg
	@echo "Wrote flat profile and flamegraph to profiling/analysis.txt and profiling/flamegraph.svg"

# Debug con GDB
debug: main_debug.x
	gdb ./main_debug.x

# Análisis con Valgrind
valgrind: main_val.x
	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes ./main_val.x 6 0.6 10

#borra archivos temporales
clean:
	rm -f *.x *.gcno *.gcda *.gcov *.data *.out *.txt gmon.out
	rm -f figures/*.x figures/*.txt 
	rm -rf build 
	rm -f profiling/out.folded profiling/perf.data
	rm -f src/*.x
	rm -f $(TEST_OBJECTS)

#flat profile
profiling-report.txt: main_pg.x
	@mkdir -p profiling
	perf record -g --output=profiling/perf.data \
	            ./main_pg.x 128 0.59271 10
	perf report --stdio --input=profiling/perf.data > profiling/profiling-report.txt
	@echo "Wrote flat profile report to profiling/profiling-report.txt"

# Compilar main.x con sanitizers y coverage
main.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -O3 $(SANITIZE_FLAGS) $(COVERAGE_FLAGS) -o $@ $(MAIN_SOURCES)

main_debug.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $@ $(MAIN_SOURCES)

main_val.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(VALGRIND_FLAGS) -o $@ $(MAIN_SOURCES)

# Profiling con gprof
main_pg.x: $(MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(PROFILE_FLAGS) -o $@ $(MAIN_SOURCES)

# Regla para compilar test.x
test.x: $(TEST_OBJECTS)
	$(CXX) $^ -o $@

# Regla genérica para compilar cualquier .cpp → .o
%.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Niveles de optimización para time_main
OPTIMIZATION_LEVELS = 1 3
TIME_EXECUTABLES = $(foreach opt,$(OPTIMIZATION_LEVELS),time_mainO$(opt).x)

# Compilar time_main con diferentes niveles de optimización
time_mainO%.x: $(TIME_MAIN_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -O$* $(SANITIZE_FLAGS) -o $@ $(TIME_MAIN_SOURCES)

# Target para ejecutar los experimentos de tiempo
$(TIME_FILES): $(TIME_EXECUTABLES) probabilidades10.txt
	parallel './time_mainO{1}.x {3} {2} >> time-{1}-{3}.txt' ::: 1 3 ::: $$(cat probabilidades10.txt) ::: {100..2000..100}

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

# Regla para generar los archivos de datos individualmente
$(DATA_FILES): 
	@echo "Los archivos de datos no existen. Ejecutando simulación..."
	@$(MAKE) run-simulation

# Compilar programa de visualización
figures/visualization.x: $(VISUALIZATION_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(VISUALIZATION_SOURCES)

# Compilar programa de visualización de clusters
figures/clustervisualization.x: $(CLUSTERVIS_SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(CLUSTERVIS_SOURCES)

# Generar figuras (depende de datos y programas de visualización)
$(FIGURE_FILES): figures/visualization.x figures/clustervisualization.x $(DATA_FILES) $(TIME_FILES)
	@echo "Generando figuras..."
	./figures/visualization.x 10 0.5 0.6 > figures/data1.txt
	./figures/visualization.x 10 0.58 15 > figures/data2.txt
	python3 ./figures/visualize.py
	./figures/clustervisualization.x 10 0.5 0.6 > figures/data_clusters1.txt
	./figures/clustervisualization.x 10 0.58 15 > figures/data_clusters2.txt 
	./figures/clustervisualization.x 500 0.55 0.6 > figures/data_clusters3.txt
	./figures/clustervisualization.x 500 0.595 0.6 > figures/data_clusters4.txt
	python3 ./figures/clustervisualize.py
	python3 ./figures/figures.py
	python3 ./figures/time_figure.py
	@echo "Figuras generadas exitosamente"


# Target para generar figuras manualmente
figures: $(FIGURE_FILES)

# Helper target para verificar figuras, en caso de no existir las crea
check-figures:
	@missing_figs=""; \
	for fig in $(FIGURE_FILES); do \
		if [ ! -f "$$fig" ]; then \
			missing_figs="$$missing_figs $$fig"; \
		fi; \
	done; \
	if [ -n "$$missing_figs" ]; then \
		echo "Error: Figuras faltantes:$$missing_figs, creandolas"; \
		$(MAKE) figures; \
		exit 1; \
	fi
	
# Limpiar solo figuras (útil para forzar regeneración)
clean-figures:
	rm -f $(FIGURE_FILES) figures/*.txt

help:
	@echo "Targets disponibles:"
	@echo "  simul          		- Compilación y simulación con L=4, p=0.6 y seed=10"
	@echo "  test					- Test con Catch2"
	@echo "  report         		- Generar reporte PDF"
	@echo "  profile        		- Profiling completo con gprof y flamegraph"
	@echo "  debug          		- Compilar y ejecutar con GDB"
	@echo "  valgrind       		- Análisis de memoria con Valgrind"
	@echo "  clean          		- Limpiar archivos temporales generados"
	@echo "  profiling-report.txt	- Genera el flat profile para L=128, p=0.59271"
	@echo "  run-simulation 		- Ejecutar simulación y genera datos para las graficas/analisis"
	@echo "  figures        		- Generar figuras (solo si no existen)"
	@echo "  clean-figures  		- Limpiar solo las figuras"
	@echo "  check-figures			- Revisa si las graficas necesarias para el reporte estan hechas, sino, las hace"
	@echo "  help           		- Mostrar esta ayuda"