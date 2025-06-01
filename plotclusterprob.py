import numpy as np
import matplotlib.pyplot as plt

def load_data(filename):
    # Intenta leer como UTF-16 (para archivos con BOM)
    try:
        with open(filename, "r", encoding="utf-16") as f:
            lines = f.readlines()
            lines = [line.strip().replace("\ufeff", "") for line in lines if line.strip()]
        data = np.array([list(map(float, line.split("\t"))) for line in lines])
        return data
    except UnicodeError:
        # Si falla, intenta con UTF-8 (sin BOM o con BOM)
        try:
            with open(filename, "r", encoding="utf-8-sig") as f:  # "-sig" maneja BOM
                lines = f.readlines()
                lines = [line.strip() for line in lines if line.strip()]
            data = np.array([list(map(float, line.split("\t"))) for line in lines])
            return data
        except Exception as e:
            print(f"Error al leer el archivo: {e}")
            return None

# Cargar datos
data = load_data("prob.txt")

fig, ax = plt.subplots()
#ax.plot(data[:, 1], data[:, 2], label="L = 3", color='red', linestyle='-', marker='o', markeredgecolor='black')
ax.plot(data[:, 1], data[:, 2], label="L = 3", color='red', linestyle='none', marker='.', markersize=1)

plt.xlabel("Probability p")
plt.ylabel("Cluster probability P")
#plt.xscale("log")
plt.grid(True)
plt.legend()
plt.savefig("prob.png", dpi=300, bbox_inches='tight')
plt.show()