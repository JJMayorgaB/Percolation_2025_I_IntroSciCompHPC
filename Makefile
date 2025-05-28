CXX=g++
CXXFLAGS = -Wall -std=c++17 -Iinclude
SRC=$(wildcard source/*.cpp)
OUT= build/percolation

build:$(OUT)

$(OUT):$(SRC)
	mkdir -p build
	$(CXX) $(CXXFLAGS) -o $(OUT) $(SRC)

run:build
	./$(OUT) 4 0.4

clean:
	rm -rf build