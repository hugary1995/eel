#%% sad
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(5, 5))

alphas = [0.1, 1, 10]
Ms = [0.1, 1, 10]

for alpha in alphas:
    for M in Ms:
        data = pd.read_csv("sad-out/sad_a{:}_m{:}_T800_load200.csv".format(alpha, M))
        ax.loglog(
            data["time"]/1000, data["Eyy_dot"], label="alphai/alpha = {:}, Mi/M = {:}".format(alpha, M)
        )
        # ax.plot(data["time"]/1000, data["cavity_density"]/data["cavity_density"][0], label="alphai/alpha = {:}, Mi/M = {:}".format(alpha, M))

ax.set_xlim([12, 100])
# ax.set_ylim([0.95, 1.2])
ax.set_xlabel("time (1e3)")
ax.set_ylabel("strain rate")
# ax.set_ylabel("cavity density")

ax.set_title("stress-aided diffusion [ON], nucleation [OFF]")
ax.legend()

# %% nucleation
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(5, 5))

Nrs = [0.1, 1, 10]
Ms = [0.1, 1, 10]

for Nr in Nrs:
    for M in Ms:
        data = pd.read_csv("nuc-out/nuc_nr{:}_m{:}_T800_load200.csv".format(Nr, M))
        # ax.plot(
        #     data["time"]/1000, data["Eyy_dot"], label="Nri/Nr = {:}, Mi/M = {:}".format(Nr, M)
        # )
        ax.plot(data["time"]/1000, data["cavity_density"]/data["cavity_density"][0], label="Nri/Nr = {:}, Mi/M = {:}".format(Nr, M))

ax.set_xlim([12, 100])
# ax.set_ylim([0.8e-6, 2.2e-6])
ax.set_ylim([0.95, 1.2])
ax.set_xlabel("time (1e3)")
# ax.set_ylabel("strain rate")
ax.set_ylabel("cavity density")

ax.set_title("stress-aided diffusion [OFF], nucleation [ON]")
ax.legend()
# %%
