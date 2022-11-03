import mooseutils
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from pathlib import Path
import sys


def interpolate(data, frames):
    tp = data["time"].to_numpy()
    Cp = data["C"].to_numpy()
    Vp = data["V"].to_numpy()
    t = np.linspace(min(tp), max(tp), frames)
    C = np.interp(t, tp, Cp)
    V = np.interp(t, tp, Vp)
    return t, C, V


Path("curves").mkdir(parents=True, exist_ok=True)

# Postprocessor values
t_1, C_1, V_1 = interpolate(
    mooseutils.PostprocessorReader(sys.argv[1]), int(sys.argv[2]))
t_2, C_2, V_2 = interpolate(
    mooseutils.PostprocessorReader(sys.argv[3]), int(sys.argv[4]))
t_3, C_3, V_3 = interpolate(
    mooseutils.PostprocessorReader(sys.argv[5]), int(sys.argv[6]))

ts = np.concatenate((t_1, t_2, t_3))
Cs = np.concatenate((C_1, C_2, C_3))
Vs = np.concatenate((V_1, V_2, V_3))

for i, t in enumerate(ts):
    print("writing C step {}".format(i))

    fig = Figure(figsize=(6, 3), dpi=120)
    ax = fig.gca()
    ax.axvspan(min(t_1), min(t_2), alpha=0.05, color='red')
    ax.axvspan(min(t_2), min(t_3), alpha=0.05, color='green')
    ax.axvspan(min(t_3), max(t_3), alpha=0.05, color='blue')
    ax.plot(ts, Cs, 'k-')
    ax.plot(ts[i], Cs[i], 'ro')
    ax.set_xlim(min(ts), max(ts))
    ax.set_ylim(0)
    ax.set_xlabel('Time [s]')
    ax.set_ylabel('Capacity [mA s]')
    fig.tight_layout()
    fig.savefig("curves/C_"+f'{i:03}'+".png")


for i, t in enumerate(ts):
    print("writing V step {}".format(i))

    fig = Figure(figsize=(6, 3), dpi=120)
    ax = fig.gca()
    ax.axvspan(min(t_1), min(t_2), alpha=0.05, color='red')
    ax.axvspan(min(t_2), min(t_3), alpha=0.05, color='green')
    ax.axvspan(min(t_3), max(t_3), alpha=0.05, color='blue')
    ax.plot(ts, Vs, 'k-')
    ax.plot(ts[i], Vs[i], 'ro')
    ax.set_xlim(min(ts), max(ts))
    ax.set_ylim(0)
    ax.set_xlabel('Time [s]')
    ax.set_ylabel('Voltage [V]')
    fig.tight_layout()
    fig.savefig("curves/V_"+f'{i:03}'+".png")


for i, t in enumerate(ts):
    print("writing CV step {}".format(i))

    fig = Figure(figsize=(6, 3), dpi=120)
    ax = fig.gca()
    ax.plot(Cs, Vs, 'k-')
    ax.plot(Cs[i], Vs[i], 'ro')
    ax.set_xlim(min(Cs), max(Cs))
    ax.set_ylim(0)
    ax.set_xlabel('Capacity [mA s]')
    ax.set_ylabel('Voltage [V]')
    fig.tight_layout()
    fig.savefig("curves/CV_"+f'{i:03}'+".png")
