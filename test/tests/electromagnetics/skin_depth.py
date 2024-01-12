import numpy as np
import pandas as pd
from scipy.interpolate import interp1d
from scipy.optimize import brentq
import matplotlib.pyplot as plt

nstep = 20
freq_max = 100
freqs = np.linspace(0, freq_max, nstep + 1)
deltas = np.empty((nstep))
sigma = 1e7
mu = 1.26e-5


def skin_depth_analytical(f):
    delta = 1 / np.sqrt(np.pi * f * sigma * mu)
    return delta


for i in range(nstep):
    data = pd.read_csv("induction_2D_csv_current_{:04d}.csv".format(i + 1))
    x = data["x"]
    ie = data["ie"]
    ie_interp = interp1d(x, ie)
    ies = np.max(ie)
    x_delta = brentq(lambda x: ie_interp(x) - ies / np.e, np.min(x), np.max(x))
    deltas[i] = np.max(x) - x_delta

fig, ax = plt.subplots()
ax.plot(freqs[1:], deltas, "ko", label="Simulation")
freq_analytical = np.linspace(freq_max / 100, freq_max, 100)
ax.plot(
    freq_analytical, skin_depth_analytical(freq_analytical), "r--", label="Analytical"
)
ax.set_xlabel("Frequency (Hz)")
ax.set_ylabel("Skin depth (m)")
ax.legend()
fig.tight_layout()
fig.savefig("skin_depth.png")
