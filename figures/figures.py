import matplotlib.pyplot as plt
import numpy as np

# Configuración del gráfico
fig, ax = plt.subplots(figsize=(10, 7))

# Estilos personalizados (igual que antes)
styles = [
    {'color': '#FF0000', 'marker': 'o', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-', 'alpha': 1.0},
    {'color': '#00AA00', 'marker': 'P', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 0.9},
    {'color': '#0000FF', 'marker': 'D', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 0.9},
    {'color': '#FF00FF', 'marker': '^', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 0.9},
    {'color': 'c', 'marker': 's', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 0.9}
]

# Tamaños de red
Ls = [32, 64, 128, 256, 512]

# Leer y graficar cada archivo
for i, L in enumerate(Ls):
    try:
        data = np.loadtxt(f"build/graficas/L{L}_Cluster.txt")
        p = data[:, 0]
        cluster_size = data[:, 1]
        error = data[:, 2]
        
        ax.errorbar(p, cluster_size, yerr=error,
                   label=f'L = {L}',
                   **styles[i],
                   capsize=2.5,
                   elinewidth=0.8)
    except FileNotFoundError:
        print(f"Advertencia: No se encontró el archivo para L={L}_Cluster.txt")

# Configuración de ejes y título
ax.set_title("Tamaño normalizado del clúster percolante para diferentes L", 
             fontsize=11, pad=15)
ax.set_xlabel("Probabilidad p", fontsize=11)
ax.set_ylabel("Tamaño normalizado del clúster", fontsize=11)

# Ajustes de estilo
ax.grid(True, linestyle=':', alpha=0.7)
ax.legend(loc='upper left', framealpha=0.95, fontsize=10)
ax.set_xlim(0.4, 1)
ax.set_ylim(-0.1, 1.1)

# Guardar sin tight_layout para evitar problemas
plt.savefig("figures/Cluster_all_L.png", bbox_inches='tight', dpi=300)
#plt.savefig("figures/Cluster_all_L.pdf", bbox_inches='tight', dpi=300)

plt.close()

#GRAFICO 2
fig, ax = plt.subplots(figsize=(10, 7))

# Estilos personalizados (igual que antes)
styles = [
    {'color': '#FF0000', 'marker': 'o', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-', 'alpha': 1.0},
    {'color': '#00AA00', 'marker': 'P', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 1.0},
    {'color': '#0000FF', 'marker': 'D', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 1.0},
    {'color': '#FF00FF', 'marker': '^', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 1.0},
    {'color': 'c', 'marker': 's', 'markersize': 3, 'linewidth': 0.8, 'markeredgewidth': 0.5,'linestyle': '-','alpha': 1.0}
]

# Tamaños de red
Ls = [32, 64, 128, 256, 512]

# Leer y graficar cada archivo
for i, L in enumerate(Ls):
    try:
        data = np.loadtxt(f"build/graficas/L{L}_P.txt")
        p = data[:, 0]
        cluster_size = data[:, 1]
        error = data[:, 2]
        
        ax.errorbar(p, cluster_size, yerr=error,
                   label=f'L = {L}',
                   **styles[i],
                   capsize=2.5,
                   elinewidth=0.8)
    except FileNotFoundError:
        print(f"Advertencia: No se encontró el archivo para L={L}_P.txt")

# Configuración de ejes y título
ax.set_title("Probabilidad de que exista un clúster percolante para diferentes L", 
             fontsize=11, pad=15)
ax.set_xlabel("Probabilidad p", fontsize=11)
ax.set_ylabel("Probabilidad de que exista un clúster percolante P ", fontsize=11)

# Ajustes de estilo
ax.grid(True, linestyle=':', alpha=0.7)
ax.legend(loc='upper left', framealpha=0.95, fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(-0.1, 1.1)

# Guardar sin tight_layout para evitar problemas
plt.savefig("figures/P_all_L.png", bbox_inches='tight', dpi=300)
#plt.savefig("figures/Cluster_all_L.pdf", bbox_inches='tight', dpi=300)

plt.close()