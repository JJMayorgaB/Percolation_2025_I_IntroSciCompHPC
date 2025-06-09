#!/bin/bash

EXEC="./percolacion"

# Crear carpetas necesarias
rm -rf  ../build


mkdir -p ../build/resultados/raw_data/Pfiles
mkdir -p ../build/resultados/raw_data/Clusters
mkdir -p ../build/graficas
rm -r graficas
# Valores de L
Ls=(3 32 64 128 256 512)

# Generar valores de p (20 uniformes y 10 críticos)
ps=()
for i in $(seq 0 20); do
    val=$(awk -v i=$i 'BEGIN {printf "%.5f", i * 0.05}')
    ps+=($val)
done

for i in $(seq 0 12); do
    val=$(awk -v i=$i 'BEGIN {printf "%.5f", 0.55 + i * 0.01}')
    ps+=($val)
done

# Ordenar y eliminar duplicados
ps=($(printf "%s\n" "${ps[@]}" | sort -n | uniq))

# Crear combinaciones
combinations="combinations.txt"
> "$combinations"
for L in "${Ls[@]}"; do
    for p in "${ps[@]}"; do
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




   #read avg < <(
    #awk '$1 > 0 { x += $1; n++ }
        #END { if (n > 0) printf "%.5f\n", x / n; else print 0 }' "$raw_file"
    #)

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

    #prob=$(awk -v count="$percolating_count" 'BEGIN {printf "%.3f", count / 10}')

    #echo "$L,$p,$avg,$std,$prob"
    #mkdir -p graficas
    #echo "$p $prob" >> graficas/L${L}.txt

    #sort -n graficas/L${L}.txt -o graficas/L${L}.txt

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

}


export -f simulate
export EXEC

# Encabezado del resumen CSV

echo "L,p,promedio_cluster_percolante,desviacion_cluster_percolante,media_P,desviacion_P" > resultados/resumen.csv

# Ejecutar en paralelo
parallel --colsep ' ' simulate {1} {2} :::: "$combinations" >> resultados/resumen.csv

# Limpieza
rm -r resultados/temp "$combinations"


for L in "${Ls[@]}" ; do
    sort -n ../build/graficas/L${L}_P.txt -o ../build/graficas/L${L}_P.txt
    sort -n ../build/graficas/L${L}_Cluster.txt -o ../build/graficas/L${L}_Cluster.txt
done


for L in "${Ls[@]}" ; do
    gnuplot -persist <<-EOF
        set terminal pngcairo size 800,600
        set output "../build/graficas/L${L}_P.png"
        set title "Probabilidad de percolación para L=$L"
        set xlabel "p"
        set ylabel "P"
        set grid
        set key top left
        plot "../build/graficas/L${L}_P.txt" using 1:2:3 with yerrorlines title 'P vs p (error)
EOF

    gnuplot -persist <<-EOF
        set terminal pngcairo size 800,600
        set output "../build/graficas/L${L}_Cluster.png"
        set title "Tamaño normalizado del clúster percolante para L=$L"
        set xlabel "p"
        set ylabel "Tamaño normalizado de cluster percolante"
        set grid
        set key top left
        plot "../build/graficas/L${L}_Cluster.txt" using 1:2:3 with yerrorlines title 'Cluster vs p (error)

EOF
done


#for L in "${Ls[@]}" ; do
    #sort -n graficas/L$L.txt -o graficas/L$L.txt
#done

echo "✅ Simulaciones y gráficas completadas."
echo "📂 Ver resultados en: build/graficas/"

