CXX = g++ -I include/
CXXFLAGS = -fsanitize=address,undefined,leak -fprofile-arcs -ftest-coverage
DEBUGFLAGS = -g -ggdb -O0 
VALGRINDFLAGS = -g -O1
COVERAGEFLAGS = -g -coverage -fprofile-arcs -ftest-coverage
SOURCES = src/main.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp

FLAME = $(HOME)/Downloads/FlameGraph

main.x: $(SOURCES)
	$(CXX) $(CXXFLAGS) -o $@ $^

debug:
	$(CXX) $(DEBUGFLAGS) $(SOURCES) -o main_debug.x
	gdb ./main_debug.x

valgrind:
	$(CXX) $(VALGRINDFLAGS) $(SOURCES) -o main_val.x
	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes ./main_val.x 6 0.6 10

percolacion_pg.x: main.cpp functions_dfsviejo.cpp
	$(CXX) $(CXXFLAGS) -O0 -pg -g -fno-inline $^ -o $@ 


#flat-profile crítico -> profiling-report.txt (L=128, pc \approx 0.59271)
profiling-report.txt: percolacion_pg.x
	@mkdir -p profiling
	# graba un perfil estadístico en UNA pasada
	perf record -g --output=profiling/perf.data \
	            ./percolacion_pg.x 128 0.59271 10
	# vuelca un flat profile en texto
	perf report --stdio --input=profiling/perf.data > profiling-report.txt

profile: percolacion_pg.x #revisar si puede poner solo las funciones de interés
	@mkdir -p profiling
	./percolacion_pg.x 1000 0.5 10 
	gprof percolacion_pg.x gmon.out | grep -v 'std::\|__gnu_cxx\|operator\|std::chrono\|std::__' > profiling/analysis.txt

	perf record --call-graph dwarf -F99 -g -- ./percolacion_pg.x 1000 0.5 10
	perf script | $(FLAME)/stackcollapse-perf.pl > profiling/out.folded
	$(FLAME)/flamegraph.pl profiling/out.folded > profiling/flamegraph.svg

	@echo "Wrote flat profile and flamegraph to profiling/analysis.txt and profiling/flamegraph.svg"


clean:
	rm -f *.x *.gcno *.gcda