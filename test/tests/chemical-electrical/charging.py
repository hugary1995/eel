import numpy as np
import matplotlib.pyplot as plt
import mooseutils

data = mooseutils.PostprocessorReader("charging_out.csv")

C = data["C"]
V = data["V"]
mass_a = data["mass_a"]
mass_c = data["mass_c"]
mass_e = data["mass_e"]

fig, (ax1, ax2) = plt.subplots(2, 1)

ax1.plot(C / np.max(C) * 100, V)
ax1.set_xlim(-1, 101)
ax1.set_ylim(0)
ax1.set_xlabel("Normalized capacity [%]")
ax1.set_ylabel("Voltage [V]")

ax2.fill_between(V, mass_e, label="elyte")
ax2.fill_between(V, mass_e, mass_e + mass_c, label="cathode")
ax2.fill_between(V, mass_e + mass_c, mass_e + mass_c + mass_a, label="anode")
ax2.set_xlim(0)
ax2.set_ylim(0)
ax2.set_xlabel("Voltage [V]")
ax2.set_ylabel("Total mass [mmol]")
ax2.legend()

fig.tight_layout()
plt.show()
