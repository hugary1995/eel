#%%
# post script for averaged cavity density and displacements at Point A and 
# Point B for single grain (GB) tests

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scienceplots

fig, ax = plt.subplots(3, 2, figsize=(10, 8))

plt.style.use('science')

# load data
data = pd.read_csv("../gold/single_conserv_load50_Mi1e-8_M1e-16_Nri1e-3.csv")

# plot avergaed cavity density over time
ax[0][0].plot(data["time"], data["cavity_density"], label='averaged cavity density total')
ax[0][0].plot(data["time"], data["cavity_density_bulk"], label='averaged cavity density in grain')
ax[0][0].legend()
ax[0][0].set_title("Averaged cavity density")
ax[0][0].set_xlabel("Time")
ax[0][0].set_ylabel("Cavity density")

# plot cavity density at Point A and Point B over time
ax[0][1].plot(data["time"], data["PA_c"], label='Point A at (0, 0.9)')
ax[0][1].plot(data["time"], data["PB_c"], label='Point B at (0.9, 0)')
ax[0][1].legend()
ax[0][1].set_title("Cavity density at Point A and Point B")
ax[0][1].set_xlabel("Time")
ax[0][1].set_ylabel("Cavity density")

# plot displacements at Point A
ax[1][0].plot(data["time"], data["PA_ux"], label='ux')
ax[1][0].plot(data["time"], data["PA_uy"], label='uy')
ax[1][0].legend()
ax[1][0].set_title("Displacements at Point A")
ax[1][0].set_xlabel("Time")
ax[1][0].set_ylabel("Dispalcement")

# plot displacements at Point B
ax[1][1].plot(data["time"], data["PB_ux"], label='ux')
ax[1][1].plot(data["time"], data["PB_uy"], label='uy')
ax[1][1].legend()
ax[1][1].set_title("Displacements at Point B")
ax[1][1].set_xlabel("Time")
ax[1][1].set_ylabel("Dispalcement")

# plot strain rate at Point A
ax[2][0].loglog(data["time"], data["PA_ux_dot"], label='dot(ux)')
ax[2][0].loglog(data["time"], data["PA_uy_dot"], label='dot(uy)')
ax[2][0].legend()
ax[2][0].set_xlim([10, 10000])
ax[2][0].set_title("Strain rate at Point A")
ax[2][0].set_xlabel("Time")
ax[2][0].set_ylabel("Rate")

# plot strain rate at Point B
ax[2][1].loglog(data["time"], np.abs(data["PB_ux_dot"]), label='abs(dot(ux))')
ax[2][1].loglog(data["time"], np.abs(data["PB_uy_dot"]), label='abs(dot(uy))')
ax[2][1].legend()
ax[2][1].set_xlim([10, 10000])
ax[2][1].set_title("Absolute strain rate at Point B")
ax[2][1].set_xlabel("Time")
ax[2][1].set_ylabel("Rate")

fig.tight_layout()
# %% save fig

fig.savefig('single_conserv_gb.png')
# %%
