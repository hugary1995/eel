import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
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

wt = 80
Crate = "C3"

norm = colors.Normalize(vmin=0, vmax=20)
sm = cm.ScalarMappable(norm=norm, cmap="viridis")


def smooth_deriv(y, x):
    return savgol_filter(np.diff(y), 20, 1, mode="nearest") / savgol_filter(
        np.diff(x), 20, 1, mode="nearest"
    )


for trial in [1]:
    df = pd.read_excel("{}/{}-{}.xlsx".format(wt, Crate, trial), sheet_name="record")

    startup = 3
    cycles = df["Cycle Index"]
    step = df["Step Type"]
    min_cycle = np.min(cycles)
    max_cycle = np.max(cycles)
    C = df["Spec. Cap.(mAh/g)"]
    V = df["Voltage(V)"]

    # fig1, ax1 = plt.subplots()
    fig2, ax2 = plt.subplots()

    for i in [5, 10, 15, 20]:
        print(i)
        if i <= startup:
            continue
        if i % 5 != 0 and i != startup + 1:
            continue

        idx = (cycles == i) & (step == "CC Chg")
        Ci_chg = C.loc[idx]
        Vi_chg = V.loc[idx]
        dCidVi_chg = smooth_deriv(Ci_chg, Vi_chg)

        C0 = Ci_chg.iloc[-1]

        idx = (cycles == i) & (step == "CC DChg")
        Ci_dchg = C0 - C.loc[idx]
        Vi_dchg = V.loc[idx]
        dCidVi_dchg = -smooth_deriv(Ci_dchg, Vi_dchg)

        # ax1.plot(
        #     np.concat([Ci_chg, Ci_dchg]),
        #     np.concat([Vi_chg, Vi_dchg]),
        #     color=sm.to_rgba(i),
        # )
        ax2.plot(
            Vi_chg[1:],
            dCidVi_chg,
            "-",
            color=sm.to_rgba(i),
            label="Exp. cycle {}".format(i),
        )
        ax2.plot(Vi_dchg[1:], dCidVi_dchg, "-", color=sm.to_rgba(i))

        sim = pd.read_csv("{}/cycle-{}-sim.csv".format(wt, i))
        ax2.plot(
            sim["voltage"],
            sim["dQdV"],
            "x",
            color=sm.to_rgba(i),
            label="Sim. cycle {}".format(i),
        )

    # ax1.set_xlabel("Specific capacity (mAh/g)")
    # ax1.set_ylabel("Voltage (V)")
    # fig1.colorbar(sm, ax=ax1)
    # fig1.tight_layout()
    # fig1.savefig("{}/CV-{}-{}.png".format(wt, Crate, trial))

    ax2.set_xlabel("Voltage (V)")
    ax2.set_ylabel("Specific differential capacity (mAh/g-V)")
    ax2.set_xlim(1.8, 3.7)
    ax2.set_ylim(-350, 450)
    ax2.legend()
    # fig2.colorbar(sm, ax=ax2)
    fig2.tight_layout()
    fig2.savefig("{}/VQ.pdf".format(wt, Crate, trial, i), dpi=300)
