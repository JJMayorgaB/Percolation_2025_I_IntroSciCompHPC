import matplotlib.pyplot as plt
import numpy as np
import matplotlib.colors as mcolors

def read_matrix(file):

    try:
        with open(file, 'r', encoding='utf-16') as f:  #Predeterminado: utf-16
            lines = f.readlines()
    except UnicodeDecodeError:
        with open(file, 'r', encoding='utf-8') as f:  # Fallback a otra codificación
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

def visualize_matriz(matrix):
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
    plt.savefig("figures/percolation.png", dpi=300, bbox_inches='tight')
    plt.show()

if __name__ == "__main__":

    data = "figures/data.txt"

    try:
        matrix = read_matrix(data)

        if matrix.size > 0:
            visualize_matriz(matrix)
        else:
            print("The file does not contain a valid matrix.")

    except FileNotFoundError:
        print(f"Error: File not found: '{data}'")

    except Exception as e:
        print(f"Error: {str(e)}")