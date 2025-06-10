#!/bin/bash
EXEC="./main.x"

# Crear carpetas necesarias
rm -rf  ../build

mkdir -p ../build/resultados/raw_data/Pfiles
mkdir -p ../build/resultados/raw_data/Clusters
mkdir -p ../build/graficas

rm -r graficas

# Compilar y generar probabilidades
g++ -std=c++17 -I include -o printvalues.x printvalues.cpp probvalues.cpp
if [ $? -ne 0 ]; then
    echo "Error en la compilación"
    exit 1
fi

./printvalues.x 50 > probabilidades.txt

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
    L=$1
    p=$2

    raw_file="../build/resultados/raw_data/L${L}_p${p}.txt"
    P_file="../build/resultados/raw_data/Pfiles/L${L}_p${p}_Pvalores.txt"
    clusters_percolantes_file="../build/resultados/raw_data/Clusters/L${L}_p${p}_clusters_percolantes.txt"

    > "$raw_file"
    > "$P_file"
    > "$clusters_percolantes_file"

    cluster_perc_sizes=()

    for iter in {1..10}; do
    percolating_count=0
    for rep in {1..10}; do
        output=$(echo -e "$L\n$p" | $EXEC 2>/dev/null)
        perc=$(echo "$output" | grep -i "¿Existe percolación?" | grep -o "Sí\|No")
        size=$(echo "$output" | grep -i "Tamaño del mayor cluster percolante" | awk '{print $NF}')
        size=${size:-0}

        echo "$size" >> "$raw_file"

        if [ "$perc" == "Sí" ]; then

            percolating_count=$((percolating_count + 1))
            cluster_perc_sizes+=("$size")

        fi
    done

    P_iter=$(awk -v c="$percolating_count" 'BEGIN {printf "%.5f", c/10.0}')
    echo "$P_iter" >> "$P_file"
    P_vals+=("$P_iter")

done


    # Normalizar cluster sizes y guardar
    cluster_perc_sizes_normalized=()
    for size in "${cluster_perc_sizes[@]}"; do
        norm=$(awk -v s="$size" -v L="$L" 'BEGIN {printf "%.8f", s / (L*L)}')
        cluster_perc_sizes_normalized+=("$norm")
    done
    printf "%s\n" "${cluster_perc_sizes_normalized[@]}" >> "$clusters_percolantes_file"


     read avg_cluster std_cluster < <(
        printf "%s\n" "${cluster_perc_sizes_normalized[@]}" | awk '
            { x += $1; x2 += $1*$1; n++ }
            END {
                if (n > 1) {
                    m = x / n;
                    s = sqrt((x2 - (x*x)/n)/(n-1));
                    printf "%.5f %.5f", m, s;
                } else if (n == 1) {
                    printf "%.5f 0.00000", x;
                } else {
                    printf "0.00000 0.00000";
                }
            }
        '
    )

    read P_avg P_std < <(
    awk '{
        x += $1;
        x2 += $1 * $1;
        n++;
    }
    END {
        if (n > 1) {
            avg = x / n;
            std = sqrt((x2 - (x*x)/n) / (n - 1));
            printf "%.5f %.5f\n", avg, std;
        } else {
            print $1, 0;
        }
    }' "$P_file"
    )

    echo "$p $P_avg $P_std" >> ../build/graficas/L${L}_P.txt
    echo "$p $avg_cluster $std_cluster" >> ../build/graficas/L${L}_Cluster.txt
    echo "$L,$p,$avg_cluster,$std_cluster,$P_avg,$P_std"
}


export -f simulate
export EXEC

# Encabezado del resumen CSV
echo "L,p,promedio_cluster_percolante,desviacion_cluster_percolante,media_P,desviacion_P" > resultados/resumen.csv

# Ejecutar en paralelo y salida de datos
parallel --colsep ' ' simulate {1} {2} :::: "$combinations" > resultados/resumen_temp.csv
sort -t',' -k1,1n -k2,2n resultados/resumen_temp.csv >> resultados/resumen.csv 
rm resultados/resumen_temp.csv

# Limpieza
rm -r resultados/temp "$combinations" probabilidades.txt


for L in "${Ls[@]}" ; do
    sort -n ../build/graficas/L${L}_P.txt -o ../build/graficas/L${L}_P.txt
    sort -n ../build/graficas/L${L}_Cluster.txt -o ../build/graficas/L${L}_Cluster.txt
done

echo "✅ Simulaciones y gráficas completadas."
echo "📂 Ver resultados en: build/graficas/"