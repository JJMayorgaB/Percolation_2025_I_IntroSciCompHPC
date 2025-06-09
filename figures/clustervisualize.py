import matplotlib.pyplot as plt
import numpy as np
import matplotlib.colors as mcolors
import re

def read_matrix_and_metadata(file):
    try:
        with open(file, 'r', encoding='utf-16') as f:
            lines = f.readlines()
    except UnicodeDecodeError:
        with open(file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    
    matrix = []
    max_cols = 0
    cluster_size = None
    
    # Regular expression to find cluster size
    size_pattern = re.compile(r'Tamano maximo de cluster:\s*(\d+)', re.IGNORECASE)
    
    for line in lines:
        line = line.strip()
        
        # Search for cluster size in text lines
        size_match = size_pattern.search(line)
        if size_match:
            cluster_size = int(size_match.group(1))
            continue
        
        # Process numeric lines
        if line and not any(c.isalpha() for c in line):
            row = []
            for num in line.split():
                try:
                    row.append(int(num))
                except ValueError:
                    continue
            
            if row:
                matrix.append(row)
                if len(row) > max_cols:
                    max_cols = len(row)
    
    # Pad irregular rows with zeros
    for row in matrix:
        while len(row) < max_cols:
            row.append(0)
    
    return np.array(matrix), cluster_size

def visualize_matrix(matrix, cluster_size=None, save_path="percolation.png"):
    if matrix.size == 0:
        print("Matrix is empty. Please check the input file.")
        return

    unique_labels = np.unique(matrix)
    num_labels = len(unique_labels)
    
    # Generamos colores aleatorios bien diferenciados
    np.random.seed(42)  # Para reproducibilidad
    colors = []
    
    # Color fijo blanco para el fondo (etiqueta 0)
    if 0 in unique_labels:
        colors.append([1, 1, 1, 1])  # Blanco
        num_labels -= 1
    
    # Generamos colores HSL aleatorios con saturación y luminosidad fijas
    for i in range(num_labels):
        hue = np.random.rand()  # Matiz aleatorio entre 0 y 1
        saturation = 0.7 + np.random.rand() * 0.3  # Saturación alta (70-100%)
        lightness = 0.5 + np.random.rand() * 0.2  # Luminosidad media (50-70%)
        
        # Convertimos HSL a RGB
        rgb_color = mcolors.hsv_to_rgb([hue, saturation, lightness])
        colors.append([rgb_color[0], rgb_color[1], rgb_color[2], 1])  # Alpha=1
    
    # Mezclamos los colores (excepto el blanco que debe quedarse primero si existe)
    if 0 in unique_labels:
        non_zero_colors = colors[1:]
        np.random.shuffle(non_zero_colors)
        colors[1:] = non_zero_colors
    else:
        np.random.shuffle(colors)
    
    custom_cmap = mcolors.ListedColormap(colors)
    bounds = np.append(unique_labels, unique_labels[-1]+1) - 0.5
    norm = mcolors.BoundaryNorm(bounds, custom_cmap.N)

    
    custom_cmap = mcolors.ListedColormap(colors)
    bounds = np.append(unique_labels, unique_labels[-1]+1) - 0.5
    norm = mcolors.BoundaryNorm(bounds, custom_cmap.N)

    # Create figure with appropriate size for 100x100 matrix
    fig, ax = plt.subplots()
    img = ax.imshow(matrix, cmap=custom_cmap, norm=norm, interpolation='none')

    # Grid configuration (only show every 10th line for large matrices)
    if matrix.shape[0] > 50:
        grid_step = max(1, matrix.shape[0] // 10)
        ax.set_xticks(np.arange(-0.5, matrix.shape[1], grid_step), minor=True)
        ax.set_yticks(np.arange(-0.5, matrix.shape[0], grid_step), minor=True)
    else:
        ax.set_xticks(np.arange(-0.5, matrix.shape[1], 1), minor=True)
        ax.set_yticks(np.arange(-0.5, matrix.shape[0], 1), minor=True)
    
    ax.grid(which='minor', color='gray', linestyle='-', linewidth=0.5)
    ax.tick_params(which='minor', size=0)
    ax.set_xticks([])
    ax.set_yticks([])

    # Create title and subtitle
    title = "Percolation Process"
    if cluster_size is not None:
        if cluster_size == 0:
            title += "\nNo percolating cluster"
        else:
            title += f"\nPercolating cluster size: {cluster_size}"
    
    plt.title(title, fontsize=12)
    
    # Legend (only show if reasonable number of labels)
    if num_labels <= 20:
        legend_elements = [plt.Rectangle((0,0), 1, 1, 
                           color=colors[i], 
                           label=f'Cluster {unique_labels[i]}') 
                          for i in range(num_labels)]
        ax.legend(handles=legend_elements, title="Clusters",
                  bbox_to_anchor=(1.05, 1), loc='upper left',
                  fontsize=8, title_fontsize=9)

    # Adjust layout with constrained_layout instead of tight_layout
    fig.set_constrained_layout(True)
    plt.savefig("figures/clusterpercolation.png", dpi=300, bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    data = "figures/data_clusters.txt"
    try:
        matrix, cluster_size = read_matrix_and_metadata(data)
        print(f"Matrix loaded successfully. Dimensions: {matrix.shape}")
        if cluster_size is not None:
            print(f"Percolating cluster size: {cluster_size}")
        visualize_matrix(matrix, cluster_size)
    except FileNotFoundError:
        print(f"Error: File not found: '{data}'")
    except Exception as e:
        print(f"Error: {str(e)}")