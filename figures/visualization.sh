#!/bin/bash

# Compile and run visualization program
g++ -std=c++17 -I include/ -o figures/visualization.x figures/visualization.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp
./figures/visualization.x 10 0.5 0.6 > figures/data.txt
python3 ./figures/visualize.py

# Compile and run cluster visualization program
g++ -std=c++17 -I include/ -o figures/clustervisualization.x figures/clustervisualization.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp
./figures/clustervisualization.x 10 0.5 0.6 > figures/data_clusters.txt
python3 ./figures/clustervisualize.py

#WINDOWS

# Compile and run visualization program
g++ -std=c++17 -I include/ -o figures/visualization.exe figures/visualization.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp
./figures/visualization.exe 10 0.5 0.6 > figures/data.txt
python ./figures/visualize.py

# Compile and run cluster visualization program
g++ -std=c++17 -I include/ -o figures/clustervisualization.exe figures/clustervisualization.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp
./figures/clustervisualization.exe 10 0.5 0.6 > figures/data_clusters.txt
python ./figures/clustervisualize.py

g++ -std=c++17 -I include/ -o src/main.exe src/main.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp
./src/main.exe

g++ -std=c++17 -I include/ -o src/main2.exe src/main2.cpp src/matrix.cpp src/hoshen_kopelman.cpp src/union_find.cpp src/probvalues.cpp
./src/main2.exe

#Obtenemos los valores de probabilidad como
g++ -std=c++17 -o printvalues.exe printvalues.cpp probvalues.cpp
./printvalues.exe 50 > probabilidades.txt   
