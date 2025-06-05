g++ -std=c++17 -o visualization.exe visualization.cpp matrix.cpp dfspercolation.cpp
.\visualization.exe 10 0.5 > data.txt
python .\visualize.py

g++ -std=c++17 -o clusterprob.exe clusterprob.cpp matrix.cpp dfspercolation.cpp probvalues.cpp
.\clusterprob.exe 10 100 250 > prob.txt
python .\plotclusterprob.py

g++ -std=c++17 -o print.exe print.cpp probvalues.cpp

for L in 32 64 128 256 512; do
    .\clusterprob.exe 10 100 250 > prob.txt
done

parallel '.\clusterprob.exe {1} 20 {2} >> data-{1}.txt' ::: 8 16 32 64 128 256 512 ::: probabilidades

g++ -std=c++17 -o cluster.exe clustervisualization.cpp matrix.cpp dfspercolation.cpp hoshen_kopelman.cpp union_find.cpp