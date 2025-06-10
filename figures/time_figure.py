import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sys

sns.set()
sns.set_context("paper")
sns.set_palette("colorblind")

# Funcion para obtener promedio y desviacion estandar
def prom_desv(datos):
    try:
        return np.mean(datos), np.std(datos)
    except:
        return np.nan, np.nan
    
def main():
    # Entrada de argumentos por consola (cadenas a listas)
    L_entrada = sys.argv[1].split()
    p_entrada = sys.argv[2].split()
    OPT = [1, 3]

    # Pasar a arreglos de Numpy de numeros enteros o flotantes
    L = np.array([int(i) for i in L_entrada])
    P = np.array([float(i) for i in p_entrada])

    # Lista de colores para las figuras 1 y 2
    colors = sns.color_palette("colorblind", n_colors=len(L))

    fig, ax = plt.subplots(figsize=(10,5))    

    # Lista de colores para la figura 3
    colors = sns.color_palette("colorblind", n_colors=len(OPT))

    # Iterar sobre los optimizadores, los tamanos de matriz y probabilidades de ocupacion (Figura 3)
    # Los tiempos computacionales son para todas las probabilidades y semillas para un valor de tamaño de matriz
    for i, o in enumerate(OPT):
        WT = np.zeros(len(L))
        CT = np.zeros(len(L))
        for j, l in enumerate(L):
            wt = 0
            ct = 0
            for p in P:
                datos = np.loadtxt(f"time_{O}_{L}.txt")
                wt += np.sum(datos[:, 1])
                ct += np.sum(datos[:, 2])
            WT[j] = wt
            CT[j] = ct
        ax.plot(L, WT, label=f"Wall time - {o}", color=colors[i], marker='o', ls='--', mec='black')
        ax.plot(L, CT, label=f"CPU time - {o}", color=colors[i], marker='o', mec='black')


    ax.set_xlabel(r"Dimensiones de la matriz L")
    ax.set_ylabel(r"Tiempo")
    ax.set_title("Tiempo de computo en funcion de la dimension de la matriz L" )
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.legend(loc='center', bbox_to_anchor=(0.9, 0.6))
    ax.grid(True)
    fig.tight_layout()
    fig.savefig("time.png")

    plt.close("all")
    
main()