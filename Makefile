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

main_pg.x: $(SOURCES)
	$(CXX) $(CXXFLAGS) -O0 -pg -g -fno-inline $^ -o $@ 


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
	rm -f *.x *.gcno *.gcda *.data *.out *.txt