import numpy as np
import matplotlib.pyplot as plt
import mooseutils

Crates = ["5e-9", "6e-9", "7e-9", "8e-9", "9e-9", "1e-8"]

fig, (ax) = plt.subplots(1, 1)

for Crate in Crates:
    data = mooseutils.PostprocessorReader("I_"+Crate+".csv")

    C = data["C"]
    V = data["V"]

    ax.plot(C, V, label="C rate = "+Crate)
    ax.set_ylim(0)
    ax.set_xlabel("Capacity [mA s]")
    ax.set_ylabel("Voltage [V]")

ax.legend()
fig.tight_layout()
plt.show()
