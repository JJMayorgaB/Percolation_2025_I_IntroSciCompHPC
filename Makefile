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
	$(CXX) $(CXXFLAGS) $(DEBUGFLAGS) $(SOURCES) -o main_debug.x
	gdb ./percolacion_debug.x

valgrind:
	$(CXX) $(CXXFLAGS) $(VALGRINDFLAGS) $(SOURCES) -o main_val.x
	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes ./main_val.x 512 0.7 10

clean:
	rm -f *.x
