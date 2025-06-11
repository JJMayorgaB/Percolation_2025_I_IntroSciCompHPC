import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import glob
import os

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
    # Configuración
    OPT = [1, 3]  # Niveles de optimización
    L = list(range(100, 2100, 100))  # Tamaños de matriz: 100, 200, ..., 5000
    
    # Verificar qué archivos existen
    existing_files = glob.glob("time-*.txt")
    print(f"Archivos encontrados: {len(existing_files)}")
    
    # Crear figura
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Colores y estilos para la leyenda
    wt_color = sns.color_palette("colorblind")[0]  # Color para Wall Time
    ct_color = sns.color_palette("colorblind")[1]  # Color para CPU Time
    linestyles = ['-', '--']  # Estilos para O1 y O3
    
    # Diccionarios para almacenar datos de todos los optimizadores
    all_data = {}
    
    # Iterar sobre cada nivel de optimización
    for i, opt in enumerate(OPT):
        # Arrays para almacenar tiempos promedio y desviaciones
        WT_mean = []
        WT_std = []
        CT_mean = []
        CT_std = []
        L_valid = []  # Solo los tamaños L para los que tenemos datos
        
        # Iterar sobre cada tamaño de matriz
        for l in L:
            filename = f"time-{opt}-{l}.txt"
            
            if os.path.exists(filename):
                try:
                    # Cargar datos del archivo
                    datos = np.loadtxt(filename)
                    
                    # Extraer tiempos de wall y CPU
                    if datos.ndim == 1:  # Solo una fila
                        wt_data = [datos[1]]
                        ct_data = [datos[2]]
                    else:  # Múltiples filas
                        wt_data = datos[:, 1]  # Segunda columna (wall time)
                        ct_data = datos[:, 2]  # Tercera columna (CPU time)
                    
                    # Calcular promedio y desviación estándar
                    wt_mean, wt_std = prom_desv(wt_data)
                    ct_mean, ct_std = prom_desv(ct_data)
                    
                    # Almacenar resultados
                    WT_mean.append(wt_mean)
                    WT_std.append(wt_std)
                    CT_mean.append(ct_mean)
                    CT_std.append(ct_std)
                    L_valid.append(l)
                    
                    print(f"Opt {opt}, L={l}: WT={wt_mean:.6f}±{wt_std:.6f}, CT={ct_mean:.1f}±{ct_std:.1f}")
                    
                except Exception as e:
                    print(f"Error procesando {filename}: {e}")
            else:
                print(f"Archivo no encontrado: {filename}")
        
        # Convertir a arrays numpy y almacenar
        all_data[opt] = {
            'L': np.array(L_valid),
            'WT_mean': np.array(WT_mean),
            'WT_std': np.array(WT_std),
            'CT_mean': np.array(CT_mean),
            'CT_std': np.array(CT_std)
        }
    
    # Graficar todas las curvas
    for i, opt in enumerate(OPT):
        data = all_data[opt]
        if len(data['L']) > 0:
            # Graficar Wall Time
            ax.errorbar(data['L'], data['WT_mean'], yerr=data['WT_std'], 
                       color=wt_color, marker='o', linestyle=linestyles[i], 
                       markeredgecolor='black', capsize=5, capthick=2,
                       linewidth=2, markersize=6)
            
            # Graficar CPU Time
            ax.errorbar(data['L'], data['CT_mean']/1000, yerr=data['CT_std']/1000,
                       color=ct_color, marker='s', linestyle=linestyles[i], 
                       markeredgecolor='black', capsize=5, capthick=2,
                       linewidth=2, markersize=6)
    
    # Crear leyendas personalizadas
    from matplotlib.lines import Line2D
    
    # Leyenda para tipos de tiempo (colores)
    time_legend_elements = [
        Line2D([0], [0], color=wt_color, marker='o', linestyle='-', 
               markersize=8, label='Wall Time', markeredgecolor='black'),
        Line2D([0], [0], color=ct_color, marker='s', linestyle='-', 
               markersize=8, label='CPU Time', markeredgecolor='black')
    ]
    
    # Leyenda para optimizadores (estilos de línea)
    opt_legend_elements = [
        Line2D([0], [0], color='gray', linestyle='-', linewidth=2, label='O1'),
        Line2D([0], [0], color='gray', linestyle='--', linewidth=2, label='O3')
    ]
    
    # Crear las dos leyendas
    legend1 = ax.legend(handles=time_legend_elements, loc='upper left', 
                       title='Tipo de Tiempo', fontsize=10, title_fontsize=11)
    legend2 = ax.legend(handles=opt_legend_elements, loc='lower right', 
                       title='Optimización', fontsize=10, title_fontsize=11)
    
    # Añadir la primera leyenda de vuelta (ya que la segunda la sobrescribe)
    ax.add_artist(legend1)
    
    # Configurar la gráfica
    ax.set_xlabel(r"Dimensiones de la matriz L", fontsize=12)
    ax.set_ylabel(r"Tiempo (segundos)", fontsize=12)
    ax.set_title("Tiempo de cómputo en función de la dimensión de la matriz L", fontsize=14)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.grid(True, alpha=0.3)
    
    # Mejorar la presentación
    fig.tight_layout()

    # Guardar figura
    fig.savefig("figures/time_analysis.png", dpi=300, bbox_inches='tight')
    #fig.savefig("time_analysis.pdf", bbox_inches='tight')
    
    print("\nGráfica guardada como 'time_analysis.png' y 'time_analysis.pdf'")
    
    plt.close()

if __name__ == "__main__":
    main()