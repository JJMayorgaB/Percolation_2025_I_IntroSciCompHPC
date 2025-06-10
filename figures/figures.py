import matplotlib.pyplot as plt
import numpy as np
from matplotlib import rc

# Configuración para LaTeX
rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
rc('text', usetex=True)
plt.rcParams['text.latex.preamble'] = r'\usepackage{amsmath}'

# Configuración del gráfico
fig, ax = plt.subplots(figsize=(6, 4.5))  # Tamaño adecuado para documentos LaTeX

# Estilos personalizados (manteniendo los colores originales)
styles = [
    {'color': '#FF0000', 'marker': 'o', 'markersize': 4, 'linewidth': 1, 'markeredgewidth': 0.5},  # Rojo
    {'color': '#00AA00', 'marker': 'P', 'markersize': 5, 'linewidth': 1, 'markeredgewidth': 0.5},  # Verde
    {'color': '#0000FF', 'marker': 'D', 'markersize': 4, 'linewidth': 1, 'markeredgewidth': 0.5},  # Azul
    {'color': '#FF00FF', 'marker': '^', 'markersize': 4, 'linewidth': 1, 'markeredgewidth': 0.5},  # Magenta
    {'color': '#FFA500', 'marker': 's', 'markersize': 4, 'linewidth': 1, 'markeredgewidth': 0.5}   # Naranja
]

# Tamaños de red (ajustar según tus datos)
Ls = [32, 64, 128, 256]

# Leer y graficar cada archivo
for i, L in enumerate(Ls):
    try:
        data = np.loadtxt(f"../build/graficas/L{L}_Cluster.txt")
        p = data[:, 0]
        cluster_size = data[:, 1]
        error = data[:, 2]
        
        # Graficar con barras de error
        ax.errorbar(p, cluster_size, yerr=error,
                   label=fr'$L = {L}$',  # Notación matemática
                   **styles[i],
                   capsize=2.5,
                   linestyle='-',
                   elinewidth=0.8)
    except FileNotFoundError:
        print(f"Advertencia: No se encontró el archivo para L={L}")

# Configuración de ejes y título
ax.set_title(r'Tamaño normalizado del clúster percolante para diferentes $L$', 
             fontsize=11, pad=15)
ax.set_xlabel(r'$p$', fontsize=11)
ax.set_ylabel(r'Tamaño normalizado del clúster', fontsize=11)

# Ajustes de estilo
ax.grid(True, linestyle=':', alpha=0.7)
ax.legend(loc='upper left', framealpha=0.95, fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.1)

# Ajustar márgenes y diseño
plt.tight_layout(pad=1.5)

# Guardar en formatos adecuados para LaTeX
output_path = "../build/graficas/Cluster_all_L"
plt.savefig(f"{output_path}.pdf", bbox_inches='tight', dpi=300)
#plt.savefig(f"{output_path}.pgf", bbox_inches='tight')  # Para usar directamente con matplotlib en LaTeX
#plt.savefig(f"{output_path}.png", bbox_inches='tight', dpi=300)

plt.close()