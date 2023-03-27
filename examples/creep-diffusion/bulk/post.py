import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.linear_model import LinearRegression

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

fig, ax = plt.subplots(1, 4, figsize=(20, 5))

ep_dot_sec = np.empty(len(loads))
for i, load in enumerate(loads):
    data = pd.read_csv("out/load_" + str(load) + ".csv")
    ax[0].plot(data["time"], data["cavity_density"], label="load = " + str(load))
    ax[1].plot(data["time"], data["cavity_potential"])
    ax[2].loglog(data["time"], data["Eyy_dot"])
    ep_dot_sec[i] = data["Eyy_dot"].iloc[-1]


ax[0].legend()

ax[0].set_xlabel("time")
ax[0].set_ylabel("cavity density")
ax[0].set_xlim(1e5)

ax[1].set_xlabel("time")
ax[1].set_ylabel("cavity potential")
ax[1].set_xlim(1e5)

ax[2].set_xlabel("time")
ax[2].set_ylabel("strain rate")
ax[2].set_xlim(1e5)

reg = LinearRegression()
ax[3].plot(np.log10(loads), np.log10(ep_dot_sec), "o-")
reg.fit(np.log10(loads[:4]).reshape(-1, 1), np.log10(ep_dot_sec[:4]))
ax[3].plot(
    np.log10(loads[:4]),
    np.log10(ep_dot_sec[:4]) - 0.1,
    "r--",
    label="slope = {:.3E}".format(reg.coef_[0]),
)
reg.fit(np.log10(loads[-8:]).reshape(-1, 1), np.log10(ep_dot_sec[-8:]))
ax[3].plot(
    np.log10(loads[-8:]),
    np.log10(ep_dot_sec[-8:]) - 0.2,
    "g--",
    label="slope = {:.3E}".format(reg.coef_[0]),
)
ax[3].set_xlabel("log(load)")
ax[3].set_ylabel("log(secondary creep strain rate)")
ax[3].legend()

fig.tight_layout()

plt.show()
