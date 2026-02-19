import numpy as np
from matplotlib import pyplot as plt

x = np.linspace(1000, 150000, 100)
Q = 8e5
A = 200
y = 1 + A * np.exp(-Q / x)
plt.plot(x, y)
plt.savefig("test.png")
