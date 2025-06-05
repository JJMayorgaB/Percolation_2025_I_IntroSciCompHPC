#Ver clusters
g++ -std=c++17 -o visualization.exe visualization.cpp matrix.cpp dfspercolation.cpp
.\visualization.exe 10 0.5 > data.txt
python .\visualize.py

#Ver los clusters individualmente
g++ -std=c++17 -o cluster.exe clustervisualization.cpp matrix.cpp dfspercolation.cpp hoshen_kopelman.cpp union_find.cpp
.\cluster.exe 10 0.5 > data.txt
python clustervisualize.py

