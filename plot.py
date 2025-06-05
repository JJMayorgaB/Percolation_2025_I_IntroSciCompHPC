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
data8 = load_data("datasorted_8.txt")
data16 = load_data("datasorted_16.txt")
data32 = load_data("datasorted_32.txt")
data64 = load_data("datasorted_64.txt")
data128 = load_data("datasorted_128.txt")
data256 = load_data("datasorted_256.txt")
data512 = load_data("datasorted_512.txt")

fig, ax = plt.subplots()
#ax.plot(data[:, 1], data[:, 2], label="L = 3", color='red', linestyle='-', marker='o', markeredgecolor='black')
ax.plot(data8[:, 0], data8[:, 1], label="L = 8", color='red', linestyle='none', marker='.', markersize=1)
ax.plot(data16[:, 0], data16[:, 1], label="L = 16", color='green', linestyle='none', marker='.', markersize=1)
ax.plot(data32[:, 0], data32[:, 1], label="L = 32", color='blue', linestyle='none', marker='.', markersize=1)
ax.plot(data64[:, 0], data64[:, 1], label="L = 64", color='cyan', linestyle='none', marker='.', markersize=1)
ax.plot(data128[:, 0], data128[:, 1], label="L = 128", color='magenta', linestyle='none', marker='.', markersize=1)
ax.plot(data256[:, 0], data256[:, 1], label="L = 256", color='orange', linestyle='none', marker='.', markersize=1)
ax.plot(data512[:, 0], data512[:, 1], label="L = 512", color='brown', linestyle='none', marker='.', markersize=1)

plt.xlabel("Probability p")
plt.ylabel("Cluster probability P")
#plt.xscale("log")
plt.grid(True)
plt.legend()
plt.savefig("prob.png", dpi=300, bbox_inches='tight')
plt.show()