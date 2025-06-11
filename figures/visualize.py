import matplotlib.pyplot as plt
import numpy as np
import matplotlib.colors as mcolors

def read_matrix(file):

    try:
        with open(file, 'r', encoding='utf-8') as f:  #Predeterminado: utf-16
            lines = f.readlines()
    except UnicodeDecodeError:
        with open(file, 'r', encoding='utf-16') as f:  # Fallback a otra codificación
            lines = f.readlines()
    
    matrix = []
    
    for line in lines:
        line = line.strip()  # Limpia espacios y saltos de línea
        if not line:  # Omite líneas vacías
            continue
        
        # Filtra solo 0s y 1s
        row = []
        for num in line.split():
            if num in {'0', '1'}:
                row.append(int(num))
        
        if row:  # Añade filas no vacías
            matrix.append(row)
    
    return np.array(matrix)

def visualize_matriz(matrix, save_path="percolation.png"):
    if matrix.size == 0:
        print("La matriz está vacía. Verifica el archivo de entrada.")
        return

    # Configuración del mapa de colores (0: blanco, 1: azul)
    cmap = mcolors.ListedColormap(['white', 'royalblue'])
    
    # Crear la figura y el eje
    fig, ax = plt.subplots()
    
    # Mostrar la matriz con el colormap
    img = ax.imshow(matrix, cmap=cmap, vmin=0, vmax=1, interpolation='none')

    # --- Configuración de la cuadrícula (grid) ---
    # Establecer ticks menores para las líneas de la cuadrícula
    ax.set_xticks(np.arange(-0.5, matrix.shape[1], 1), minor=True)
    ax.set_yticks(np.arange(-0.5, matrix.shape[0], 1), minor=True)
    
    # Habilitar la cuadrícula solo para los ticks menores (líneas finas)
    ax.grid(which='minor', color='gray', linestyle='-', linewidth=0.5)
    
    # Ocultar los ticks menores (no mostrar números)
    ax.tick_params(which='minor', size=0)
    
    # Ocultar los ticks mayores (ejes X e Y)
    ax.set_xticks([])
    ax.set_yticks([])
    
    # --- Opcional: Añadir una barra de color (legend) ---
    # plt.colorbar(img, ax=ax, ticks=[0, 1], label="0: Vacío | 1: Ocupado")
    
    # Título y guardado
    plt.title("Percolation Process")
    # Save the figure
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    data_files = [
        ("figures/data1.txt", "figures/percolation1.png"),
        ("figures/data2.txt", "figures/percolation2.png")
    ]

    for data_file, output_file in data_files:
        try:
            print(f"Processing file: {data_file}")
            matrix = read_matrix(data_file)
            print(f"Matrix loaded successfully. Dimensions: {matrix.shape}")
            visualize_matriz(matrix, save_path=output_file)
            print(f"Graph saved to: {output_file}\n")
        except FileNotFoundError:
            print(f"Error: File not found: '{data_file}'")
        except Exception as e:
            print(f"Error processing file {data_file}: {str(e)}")