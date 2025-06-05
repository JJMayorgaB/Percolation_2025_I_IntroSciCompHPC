g++ -std=c++17 -o visualization.exe visualization.cpp matrix.cpp dfspercolation.cpp
.\visualization.exe 10 0.5 > data.txt
python .\visualize.py

g++ -std=c++17 -o print.exe print.cpp probvalues.cpp




g++ -std=c++17 -o cluster.exe clustervisualization.cpp matrix.cpp dfspercolation.cpp hoshen_kopelman.cpp union_find.cpp
.\cluster.exe 10 0.5 > data.txt
python clustervisualize.py

#FUNCION MAIN
#Obtenemos los valores de probabilidad como
g++ -std=c++17 -o print.exe print.cpp probvalues.cpp
.\print.exe 30 > prob.txt 

#Sacamos probabilidades, tamaños etc
g++ -std=c++17 -o clusterprob.exe clusterprob.cpp matrix.cpp dfspercolation.cpp probvalues.cpp hoshen_kopelman.cpp union_find.cpp
parallel './clusterprob.exe {1} 20 {2} >> data-{1}.txt' ::: 8 16 32 64 128 256 512 ::: $(cat probabilidades.txt)

#En caso de que la salida de los datos no se de ordenadamente, ordenamos los datos
for level in 8 16 32 64 128 256 512; do
    if [[ -f "data-$level.txt" ]]; then
        sort -nk 1 data-$level.txt > datasorted_$level.txt;
        rm data-$level.txt
    else
        echo "Error: data-$level.txt no existe."
    fi
done

#graficamos probabilidad
python plotclusterprob.py