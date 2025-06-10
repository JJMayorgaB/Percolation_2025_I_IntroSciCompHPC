EXEC="./percolacion"

# Variables que necesitas definir
REPETITIONS=10  # Número de repeticiones por simulación
NUM_SAMPLES=10 # Número de muestras por ejecución

# Crear carpetas necesarias
rm -rf ../build
mkdir -p ../build/resultados/raw_data/Pfiles
mkdir -p ../build/resultados/raw_data/Clusters
mkdir -p ../build/graficas

# Compilar y generar probabilidades
g++ -std=c++17 -I include -o printvalues.exe printvalues.cpp probvalues.cpp
if [ $? -ne 0 ]; then
    echo "Error en la compilación"
    exit 1
fi

./printvalues.exe 50 > probabilidades.txt

# Valores de L
Ls=(32 64 128 256 512)

# Crear combinaciones
combinations="combinations.txt"
> "$combinations"
for L in "${Ls[@]}"; do
    for p in $(cat probabilidades.txt); do
        echo "$L $p" >> "$combinations"
    done
done

# Función de simulación con cálculo de P
simulate() {
    local L=$1
    local p=$2
    
    raw_file="../build/resultados/raw_data/L${L}_p${p}.txt"
    P_file="../build/resultados/raw_data/Pfiles/L${L}_p${p}_Pvalores.txt"
    clusters_percolantes_file="../build/resultados/raw_data/Clusters/L${L}_p${p}_clusters_percolantes.txt"
    
    > "$raw_file"
    > "$P_file"
    > "$clusters_percolantes_file"
    
    local P_values=()
    local cluster_sizes=()
    
    for ((iter=0; iter<REPETITIONS; iter++)); do
        # Ejecutar el programa optimizado
        local output=$("$EXEC" "$L" "$NUM_SAMPLES" "$p")
        
        # Parsear resultados (formato: Lp probability mean_size)
        local probability=$(echo "$output" | awk '{print $2}')
        local mean_size=$(echo "$output" | awk '{print $3}')
        
        # Guardar valores
        echo "$probability" >> "$P_file"
        P_values+=("$probability")
        
        if (( $(echo "$probability > 0" | bc -l) )); then
            echo "$mean_size" >> "$clusters_percolantes_file"  # Corregido: era $clusters_file
            cluster_sizes+=("$mean_size")
        fi
    done
    
    # Calcular promedios y desviaciones estándar para P(p)
    local P_avg P_std
    read P_avg P_std < <(
        printf "%s\n" "${P_values[@]}" | awk '
            {
                sum += $1; 
                sum2 += $1*$1; 
                n++
            } 
            END {
                if (n > 0) {
                    avg = sum/n;
                    std = sqrt((sum2 - sum*sum/n)/n);
                    printf "%.5f %.5f", avg, std;
                } else {
                    printf "0 0";
                }
            }'
    )
    
    # Calcular promedios y desviaciones estándar para tamaños de cluster
    local size_avg size_std
    read size_avg size_std < <(
        printf "%s\n" "${cluster_sizes[@]}" | awk '
            {
                sum += $1; 
                sum2 += $1*$1; 
                n++
            } 
            END {
                if (n > 0) {
                    avg = sum/n;
                    std = sqrt((sum2 - sum*sum/n)/n);
                    printf "%.5f %.5f", avg, std;
                } else {
                    printf "0 0";
                }
            }'
    )
    
    # Guardar resultados para gráficas
    echo "$p $P_avg $P_std" >> ../build/graficas/L${L}_P.txt
    echo "$p $size_avg $size_std" >> ../build/graficas/L${L}_Cluster.txt  # Corregido: eran variables indefinidas
    
    # Mostrar resumen
    echo "$L,$p,$size_avg,$size_std,$P_avg,$P_std"
}

export -f simulate
export EXEC REPETITIONS NUM_SAMPLES  # Exportar todas las variables necesarias

# Encabezado del resumen CSV
echo "L,p,promedio_cluster_percolante,desviacion_cluster_percolante,media_P,desviacion_P" > resultados/resumen.csv  # Corregida la ruta


# Ejecutar en paralelo y salida de datos
parallel --colsep ' ' simulate {1} {2} :::: "$combinations" > resultados/resumen_temp.csv
sort -t',' -k1,1n -k2,2n resultados/resumen_temp.csv >> resultados/resumen.csv 
rm resultados/resumen_temp.csv

# Limpieza
rm "$combinations" probabilidades.txt printvalues.exe 

# Ordenar archivos de gráficas
for L in "${Ls[@]}"; do
    sort -n ../build/graficas/L${L}_P.txt -o ../build/graficas/L${L}_P.txt
    sort -n ../build/graficas/L${L}_Cluster.txt -o ../build/graficas/L${L}_Cluster.txt
done

# Generar gráfica de probabilidad (P vs p) con estilos personalizados
gnuplot -persist <<-EOF
    set terminal pngcairo size 800,600 enhanced font "Arial,12"
    set output "../build/graficas/P_all_L.png"
    set title "Probabilidad de percolación para diferentes L"
    set xlabel "p"
    set ylabel "P(p)"
    set grid
    set key top left

    # Definir estilos personalizados (colores + símbolos)
    set style line 1 lt 1 lc rgb "#FF0000" lw 1 pt 7 ps 1.0   # Rojo (círculo)
    set style line 2 lt 1 lc rgb "#00AA00" lw 1 pt 11 ps 1.0  # Verde (triángulo)
    set style line 3 lt 1 lc rgb "#0000FF" lw 1 pt 9 ps 1.0   # Azul (rombo)
    set style line 4 lt 1 lc rgb "#FF00FF" lw 1 pt 5 ps 1.0   # Magenta (cuadrado)
    set style line 5 lt 1 lc rgb "#FFA500" lw 1 pt 13 ps 1.0  # Naranja (estrella)

    plot \
    $(i=1; for L in "${Ls[@]}"; do
        echo "\"../build/graficas/L${L}_P.txt\" using 1:2:3 with yerrorlines ls $i title 'L=${L}', \\"
        ((i++))
    done | sed '$ s/,\\//')
EOF

# Generar gráfica de tamaño de clúster con los mismos estilos
gnuplot -persist <<-EOF
    set terminal pngcairo size 800,600 enhanced font "Arial,12"
    set output "../build/graficas/Cluster_all_L.png"
    set title "Tamaño normalizado del clúster percolante para diferentes L"
    set xlabel "p"
    set ylabel "Tamaño normalizado del clúster"
    set grid
    set key top left

    # Reutilizar los mismos estilos para consistencia
    set style line 1 lt 1 lc rgb "#FF0000" lw 1 pt 7 ps 1.0   # Rojo
    set style line 2 lt 1 lc rgb "#00AA00" lw 1 pt 11 ps 1.0  # Verde
    set style line 3 lt 1 lc rgb "#0000FF" lw 1 pt 9 ps 1.0   # Azul
    set style line 4 lt 1 lc rgb "#FF00FF" lw 1 pt 5 ps 1.0   # Magenta
    set style line 5 lt 1 lc rgb "#FFA500" lw 1 pt 13 ps 1.0  # Naranja

    plot \
    $(i=1; for L in "${Ls[@]}"; do
        echo "\"../build/graficas/L${L}_Cluster.txt\" using 1:2:3 with yerrorlines ls $i title 'L=${L}', \\"
        ((i++))
    done | sed '$ s/,\\//')
EOF


echo "Simulaciones y gráficas completadas."
echo "Ver resultados en: build/graficas/"
