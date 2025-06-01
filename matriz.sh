g++ -std=c++17 -o visualization.exe visualization.cpp matrix.cpp dfspercolation.cpp
.\visualization.exe 10 0.5 > data.txt
python .\visualize.py

g++ -std=c++17 -o clusterprob.exe clusterprob.cpp matrix.cpp dfspercolation.cpp
.\clusterprob.exe 10 100 > prob.txt