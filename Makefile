CXX = g++
CXXFLAGS = -std=c++17 -Wall
TARGET = percolation.x

SRCS = main.cpp matriz.cpp dfspercolation.cpp
OBJS = $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
    $(CXX) $(CXXFLAGS) -o $@ $^

clean:
    rm -f $(OBJS) $(TARGET)