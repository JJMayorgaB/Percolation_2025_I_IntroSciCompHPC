#FUNCION MAIN
#Obtenemos los valores de probabilidad como
g++ -std=c++17 -o print.exe print.cpp probvalues.cpp
./print.exe 100 > probabilidades.txt   

#Sacamos probabilidades, tamaños etc
g++ -std=c++17 -o main.exe main.cpp matrix.cpp dfspercolation.cpp probvalues.cpp hoshen_kopelman.cpp union_find.cpp
parallel './main.exe {1} 30 {2} >> data-{1}.txt' ::: 32 64 128 256 512 ::: $(cat probabilidades.txt)

#En caso de que la salida de los datos no se de ordenadamente, ordenamos los datos
for level in 32 64 128 256 512; do
    if [[ -f "data-$level.txt" ]]; then
        sort -nk 1 data-$level.txt > datasorted_$level.txt;
        rm data-$level.txt
    else
        echo "Error: data-$level.txt no existe."
    fi
done

#graficamos probabilidad y tamaños
python plot.py