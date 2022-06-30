import numpy as np
import matplotlib.pyplot as plt

c_g = np.loadtxt("charge_galvanostatic.csv", delimiter=",", skiprows=1)
c_p = np.loadtxt("charge_potentiostatic.csv", delimiter=",", skiprows=1)
d_g = np.loadtxt("discharge_galvanostatic.csv", delimiter=",", skiprows=1)
d_p = np.loadtxt("discharge_potentiostatic.csv", delimiter=",", skiprows=1)

t1 = c_g[:, 0]
soc1 = c_g[:, 1]

t2 = t1[-1] + c_p[:, 0]
soc2 = c_p[:, 1]

t3 = t2[-1] - d_g[:, 0]
soc3 = d_g[:, 1]

t4 = t3[-1] - d_p[:, 0]
soc4 = d_p[:, 1]

t_max = np.max(t2)

plt.plot(soc1, t1 / t_max, "b-", label="galvanostatic charge")
plt.plot(soc2, t2 / t_max, "r-", label="potentiostatic charge")
plt.plot(soc3, t3 / t_max, "b--", label="galvanostatic discharge")
plt.plot(soc4, t4 / t_max, "r--", label="potentiostatic discharge")

plt.xlabel("state of charge")
plt.ylabel("normalized time")
plt.legend()

plt.show()
