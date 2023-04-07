import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

Ts = np.array([700])

loads = np.array([50, 100, 150])

fig, ax = plt.subplots(figsize=(5, 5))
axd = ax.twinx()

for T in Ts:
    ep_dot_sec = np.empty(len(loads))
    for i, load in enumerate(loads):
        data = pd.read_csv("out/T_{:}_load_{:}.csv".format(T, load))
        ax.loglog(
            data["time"], data["Eyy_dot"], label="T = {:}, load = {:}".format(T, load)
        )
        axd.semilogx(data["time"], data["d"], "--")

ax.set_xlim(1e4)
ax.set_xlabel("time")
ax.set_ylabel("strain rate")
axd.set_ylabel("damage")
ax.set_title("bulk nucleation [OFF], GB nucelation [ON], GB damage [ON]")
ax.legend()

fig.tight_layout()

plt.show()
