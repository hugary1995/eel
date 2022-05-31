# Copyright 2023, UChicago Argonne, LLC All Rights Reserved
# License: L-GPL 3.0
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm, colors
from scipy.signal import savgol_filter

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


fname = "T_{}/cycle_{}_{}_I_5e-4.csv"
T = 300
ncycle = 570

DoD = []

fig1, ax1 = plt.subplots(figsize=(6, 5))
fig2, ax2 = plt.subplots(figsize=(6, 5))
fig3, ax3 = plt.subplots(figsize=(6, 5))
fig4, ax4 = plt.subplots(figsize=(6, 5))
fig5, ax5 = plt.subplots(figsize=(6, 5))
fig6, ax6 = plt.subplots(figsize=(6, 5))
fig7, ax7 = plt.subplots(figsize=(6, 5))

t0 = 0
norm = colors.Normalize(vmin=1, vmax=ncycle)
sm = cm.ScalarMappable(norm=norm, cmap="rainbow")

for cycle in range(1, ncycle + 1):
    CC_charging = pd.read_csv(fname.format(T, cycle, "CC_charging"))
    CC_discharging = pd.read_csv(fname.format(T, cycle, "CC_discharging"))

    I = np.concatenate((CC_charging["I"], CC_discharging["I"]))
    C = np.concatenate((CC_charging["C"], CC_discharging["C"]))
    V = np.concatenate((CC_charging["V"], CC_discharging["V"]))
    h = np.concatenate((CC_charging["SEI_thickness"], CC_discharging["SEI_thickness"]))
    psi = np.concatenate((CC_charging["psi_f"], CC_discharging["psi_f"]))
    D = np.concatenate((CC_charging["Di"], CC_discharging["Di"]))

    t1 = t0 + CC_charging["time"].to_numpy()
    t2 = t1[-1] + CC_discharging["time"].to_numpy()
    t = np.concatenate([t1, t2])
    t0 = t[-1]

    DoD.append(np.max(CC_discharging["C"]) - np.min(CC_discharging["C"]))

    if cycle > 1:
        ax1.plot(C * 3600, V, "-", c=sm.to_rgba(cycle))

    if cycle > 1 and cycle <= 11:
        ax3.plot(t / 3600, C * 3600, "k-")
        ax4.plot(t / 3600, V, "k-")

    ax5.plot(t / 3600, h, "k-")
    ax6.plot(t / 3600, D, "k-")
    ax7.plot(t / 3600, psi, "k-")

ax1.set_xlabel("Capacity")
ax1.set_ylabel("Voltage (V)")
fig1.colorbar(sm, ax=ax1, label="cycle")
fig1.tight_layout()
fig1.savefig("CV.png", dpi=300)

DoD_pct = DoD / DoD[0] * 100
DoD_pct_smt = savgol_filter(DoD_pct, 50, 3)
ax2.plot(DoD_pct, "k--", alpha=0.5)
ax2.plot(DoD_pct_smt, "b-")
ax2.set_ylim(50)
ax2.set_xlabel("Cycle")
ax2.set_ylabel(f"Retained capacity (\%)")
fig2.tight_layout()
fig2.savefig("degradation.png", dpi=300)

ax3.set_xlabel("Time (h)")
ax3.set_ylabel("Capacity")
fig3.tight_layout()
fig3.savefig("tC.png", dpi=300)

ax4.set_xlabel("Time (h)")
ax4.set_ylabel("Voltage (V)")
fig4.tight_layout()
fig4.savefig("tV.png", dpi=300)

ax5.set_xlabel("Time (h)")
ax5.set_ylabel("SEI thickness (mm)")
fig5.tight_layout()
fig5.savefig("th.png", dpi=300)

ax6.set_xlabel("Time (h)")
ax6.set_ylabel("Interface damage")
fig6.tight_layout()
fig6.savefig("tD.png", dpi=300)

ax7.set_xlabel("Time (h)")
ax7.set_ylabel("Interface fracture driving energy")
fig7.tight_layout()
fig7.savefig("tpsi.png", dpi=300)
