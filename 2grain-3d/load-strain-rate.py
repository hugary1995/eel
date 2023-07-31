#%% strain-rate vs load
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

loads = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200]
# loads = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

fig, ax = plt.subplots(figsize=(5, 5))

ep_dot_sec = np.empty(len(loads))
for i, load in enumerate(loads):
    data = pd.read_csv("./out/nuc-off-elastic-load/load{:}.csv".format(load))
    ep_dot_sec[i] = data["Eyy_dot"].iloc[-1]
ax.plot(np.log10(loads), np.log10(ep_dot_sec), 'o-')
# ax.plot(loads, ep_dot_sec, 'o-')

ax.set_xlabel("log(load)")
ax.set_ylabel("log(secondary creep strain rate)")
ax.set_title("bulk nucleation [OFF], GB nucelation [OFF], GB damage [OFF]")
# ax.legend()

fig.tight_layout()
# %% strain-rate vs time

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(5, 5))

loads = [10, 20, 30, 40, 50, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200]

for load in loads:
    data = pd.read_csv("load-nuc-off/load{:}.csv".format(load))
    ax.loglog(
        data["time"], data["Esyy_dot"], label="load = {:}".format(load)
    )
    # ax.plot(data["time"]/1000, data["cavity_density"]/data["cavity_density"][0], label="alphai/alpha = {:}, Mi/M = {:}".format(alpha, M))

ax.set_xlim([12000, 1e9])
# ax.set_ylim([0.95, 1.2])
ax.set_xlabel("time")
ax.set_ylabel("strain rate")
ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))
# ax.set_ylabel("cavity density")


# %%
