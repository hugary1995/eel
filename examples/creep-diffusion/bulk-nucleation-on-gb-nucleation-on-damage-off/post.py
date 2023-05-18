import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

Ts = np.array([700, 800, 900, 1000, 1100])

loads = np.array(
    [
        10,
        20,
        30,
        40,
        50,
        60,
        70,
        80,
        90,
        100,
        110,
        120,
        130,
        140,
        150,
        160,
        170,
        180,
        190,
        200,
    ]
)

fig, ax = plt.subplots(figsize=(5, 5))

for T in Ts:
    ep_dot_sec = np.empty(len(loads))
    for i, load in enumerate(loads):
        data = pd.read_csv("out/T_{:}_load_{:}.csv".format(T, load))
        ep_dot_sec[i] = data["Eyy_dot"].iloc[-1]
    ax.plot(np.log10(loads), np.log10(ep_dot_sec), "o-", label="T = {:}".format(T))

ax.set_xlabel("log(load)")
ax.set_ylabel("log(secondary creep strain rate)")
ax.set_title("bulk nucleation [ON], GB nucelation [ON], GB damage [OFF]")
ax.legend()

fig.tight_layout()

plt.savefig("results.png", bbox_inches="tight")
