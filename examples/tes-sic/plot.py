import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

exp = pd.read_csv("gold/data.csv")
sim = pd.read_csv("charging_out.csv")

t_exp = exp["Time(s)"]
t_exp = t_exp - 884.613120
t_sim = sim["time"]

fig, ax = plt.subplots()

ax.plot(t_exp / 60, exp["TC1(C)"], label="Experiment thermal couple 1", color="tab:red")
ax.plot(
    t_sim / 60,
    sim["TC1"] - 273.15,
    label="Simulation thermal couple 1",
    linestyle="--",
    color="tab:red",
)
ax.plot(
    t_exp / 60, exp["TC2(C)"], label="Experiment thermal couple 2", color="tab:green"
)
ax.plot(
    t_sim / 60,
    sim["TC2"] - 273.15,
    label="Simulation thermal couple 2",
    linestyle="--",
    color="tab:green",
)
ax.plot(
    t_exp / 60, exp["TC3(C)"], label="Experiment thermal couple 3", color="tab:blue"
)
ax.plot(
    t_sim / 60,
    sim["TC3"] - 273.15,
    label="Simulation thermal couple 3",
    linestyle="--",
    color="tab:blue",
)
ax.legend()
ax.set_xlabel("Time (min)")
ax.set_ylabel("Temperature (C)")
fig.tight_layout()
fig.savefig("comparison.png")
plt.close(fig)
