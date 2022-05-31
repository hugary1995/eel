# Copyright 2023, UChicago Argonne, LLC All Rights Reserved
# License: L-GPL 3.0
import pandas as pd
import matplotlib.pyplot as plt

SMALL_SIZE = 12
MEDIUM_SIZE = 14
BIGGER_SIZE = 16

plt.rcParams["text.usetex"] = True
plt.rc("font", size=SMALL_SIZE)  # controls default text sizes
plt.rc("axes", titlesize=SMALL_SIZE)  # fontsize of the axes title
plt.rc("axes", labelsize=MEDIUM_SIZE)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=SMALL_SIZE)  # fontsize of the tick labels
plt.rc("ytick", labelsize=SMALL_SIZE)  # fontsize of the tick labels
plt.rc("legend", fontsize=SMALL_SIZE)  # legend fontsize
plt.rc("figure", titlesize=BIGGER_SIZE)  # fontsize of the figure title

fig, ax = plt.subplots(figsize=(6, 5))
for T in [600, 700, 800]:
    data = pd.read_csv("T_target_{}.csv".format(T))
    ax.plot(
        data["time"] / 3600,
        data["T_outlet"],
        label="Target temperature = {} K".format(T),
    )

data = pd.read_csv("T_target_0.csv")
ax.plot(
    data["time"] / 3600,
    data["T_outlet"],
    "--",
    label="No feedback control".format(T),
)

ax.set_xlabel("Time (hr)")
ax.set_ylabel("Pipe outlet temperature (K)")
ax.set_ylim(0)
ax.legend()
fig.tight_layout()
fig.savefig("results.png")
