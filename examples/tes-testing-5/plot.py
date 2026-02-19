import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

exp = pd.read_csv("gold/data.csv")
sim = pd.read_csv("charging_out.csv")

t_exp = exp["Time(s)"]
t_exp = t_exp - t_exp[0]
t_sim = sim["time"]

fig, ax = plt.subplots()
ax.plot(t_exp / 60, exp["bottom1(C)"], label="Experiment container bottom 1", color="k")
ax.plot(
    t_exp / 60,
    exp["bottom2(C)"],
    label="Experiment container bottom 2",
    color="k",
    linestyle=":",
)
ax.plot(
    t_sim / 60,
    sim["bottom"] - 273.15,
    label="Simulation container bottom average",
    linestyle="--",
    color="k",
)
ax.plot(t_exp / 60, exp["TC4(C)"], label="Experiment thermal couple 4", color="tab:red")
ax.plot(
    t_sim / 60,
    sim["TC4"] - 273.15,
    label="Simulation thermal couple 4",
    linestyle="--",
    color="tab:red",
)
ax.plot(
    t_exp / 60, exp["TC5(C)"], label="Experiment thermal couple 5", color="tab:green"
)
ax.plot(
    t_sim / 60,
    sim["TC5"] - 273.15,
    label="Simulation thermal couple 5",
    linestyle="--",
    color="tab:green",
)
ax.plot(
    t_exp / 60, exp["TC6(C)"], label="Experiment thermal couple 6", color="tab:blue"
)
ax.plot(
    t_sim / 60,
    sim["TC6"] - 273.15,
    label="Simulation thermal couple 6",
    linestyle="--",
    color="tab:blue",
)
ax.legend()
ax.set_xlabel("Time (min)")
ax.set_ylabel("Temperature (C)")
fig.tight_layout()
fig.savefig("comparison.png")
plt.close(fig)
