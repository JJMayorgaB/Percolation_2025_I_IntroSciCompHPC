#!/bin/bash

# Ejecutables (definidos por el Makefile)
EXEC="./main.x"

# Compilar y preparar todo usando Makefile
echo "🔧 Preparando proyecto con Makefile..."
make all setup
if [ $? -ne 0 ]; then
    echo "❌ Error en la preparación del proyecto"
    exit 1
fi

# Valores de L
Ls=(32 64 128 256 512)

# Crear combinaciones usando el archivo ya generado por make
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

    raw_file="build/resultados/raw_data/L${L}_p${p}.txt"
    P_file="build/resultados/raw_data/Pfiles/L${L}_p${p}_Pvalores.txt"
    clusters_percolantes_file="build/resultados/raw_data/Clusters/L${L}_p${p}_clusters_percolantes.txt"

    > "$raw_file"
    > "$P_file"
    > "$clusters_percolantes_file"

    cluster_perc_sizes=()
    P_vals=()

    for iter in {1..10}; do
        percolating_count=0
        for rep in {1..10}; do
            output=$(${EXEC} $L $p 2>/dev/null)
            perc=$(echo "$output" | grep -i "¿Existe percolacion?" | grep -o "Si\|No")
            size=$(echo "$output" | grep -i "Tamaño del mayor cluster percolante" | awk '{print $NF}')
            size=${size:-0}

            echo "$size" >> "$raw_file"

            if [ "$perc" == "Si" ]; then
                percolating_count=$((percolating_count + 1))
                cluster_perc_sizes+=("$size")
            fi
        done

        P_iter=$(awk -v c="$percolating_count" 'BEGIN {printf "%.5f", c/10.0}')
        echo "$P_iter" >> "$P_file"
        P_vals+=("$P_iter")
    done

    # Calcular estadísticas de clusters
    if [ ${#cluster_perc_sizes[@]} -gt 0 ]; then
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
    else
        avg_cluster="0.00000"
        std_cluster="0.00000"
    fi

    # Calcular estadísticas de P
    read P_avg P_std < <(
        printf "%s\n" "${P_vals[@]}" | awk '
            { x += $1; x2 += $1*$1; n++ }
            END {
                if (n > 1) {
                    avg = x / n;
                    std = sqrt((x2 - (x*x)/n) / (n - 1));
                    printf "%.5f %.5f", avg, std;
                } else if (n == 1) {
                    printf "%.5f 0.00000", x;
                } else {
                    printf "0.00000 0.00000";
                }
            }
        '
    )

    echo "$p $P_avg $P_std" >> build/graficas/L${L}_P.txt
    echo "$p $avg_cluster $std_cluster" >> build/graficas/L${L}_Cluster.txt
    echo "$L,$p,$avg_cluster,$std_cluster,$P_avg,$P_std"
}

export -f simulate
export EXEC

# Encabezado del resumen CSV
echo "L,p,promedio_cluster_percolante,desviacion_cluster_percolante,media_P,desviacion_P" > build/resultados/resumen.csv

# Ejecutar en paralelo
echo "🚀 Ejecutando simulaciones en paralelo..."
parallel --colsep ' ' simulate {1} {2} :::: "$combinations" > build/resultados/resumen_temp.csv
sort -t',' -k1,1n -k2,2n build/resultados/resumen_temp.csv >> build/resultados/resumen.csv 
rm build/resultados/resumen_temp.csv

# Limpieza
rm -f "$combinations"

# Ordenar archivos de gráficas
echo "📊 Ordenando archivos de resultados..."
for L in "${Ls[@]}"; do
    if [ -f "build/graficas/L${L}_P.txt" ]; then
        sort -n build/graficas/L${L}_P.txt -o build/graficas/L${L}_P.txt
    fi
    if [ -f "build/graficas/L${L}_Cluster.txt" ]; then
        sort -n build/graficas/L${L}_Cluster.txt -o build/graficas/L${L}_Cluster.txt
    fi
done

echo "✅ Simulaciones completadas."
echo "📂 Ver resultados en: build/graficas/"
echo "📊 Resumen CSV en: build/resultados/resumen.csv"