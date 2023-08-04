#%%
# post script for averaged cavity density, strain Eyy and strain rate Eyy_dot

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scienceplots

fig, ax = plt.subplots(1, 3, figsize=(20, 3))

plt.style.use('science')

# load data
data = pd.read_csv("../gold/4grians_conserv_periodic_bc_load10_a-1e-3_ai-1e-3_Mi1e-16_M1e-11_Nri1e-6.csv")

# plot averaged cavity density over time
ax[0].plot(data["time"], data["cavity_density"], label='averaged cavity density total')
# ax[0].legend()
ax[0].set_title("Averaged cavity density")
ax[0].set_xlabel("Time")
ax[0].set_ylabel("Cavity density")

# plot Eyy
ax[1].plot(data["time"], data["Eyy"], label='Eyy')
ax[1].plot(data["time"], data["Esyy"], label='Esyy')
ax[1].legend()
ax[1].set_xlim([600, 30000])
ax[1].set_title("Strain")
ax[1].set_xlabel("Time")
ax[1].set_ylabel("Strain")

# plot Eyy_dot
ax[2].loglog(data["time"], (data["Eyy_dot"]), label='Eyy_dot')
ax[2].plot(data["time"], data["Esyy_dot"], label='Esyy_dot')
ax[2].legend()
ax[2].set_xlim([600, 30000])
ax[2].set_title("Strain rate")
ax[2].set_xlabel("Time")
ax[2].set_ylabel("Strain rate")
# %%

fig.savefig('4grains_conserv_periodic_bc_2.png')
# %%
