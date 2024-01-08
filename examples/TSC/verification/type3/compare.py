#!/usr/bin/env python

import argparse
import pandas as pd
from pathlib import Path
from matplotlib import pyplot as plt
import numpy as np
from scipy.signal import savgol_filter


def get_results(dir, BC, var):
    spacings = []
    sigmas = []
    for file in dir.glob("{}_*.csv".format(BC)):
        spacings.append(float(file.stem.split("_")[3]))
        data = pd.read_csv(file)
        sigmas.append(data[var].iloc[-1])
    spacings = np.array(spacings)
    sigmas = np.array(sigmas)
    ind = np.argsort(spacings)
    return spacings[ind], savgol_filter(sigmas[ind], 6, 2)


def make_plot(args, BC, variable):
    fig, ax = plt.subplots()

    dir = Path(args.o)
    spacings, sigmas = get_results(dir, BC, variable)
    ax.plot(spacings / args.fa, sigmas, "r.-", label="1D")
    ax.axhline(args.sigmam, ls="-", c="k", label="Matrix conductivity")

    ax.set_xlabel("Type III contact gap normalized by fiber length")
    ax.set_ylabel("Homogenized electrical conductivity")
    ax.legend()
    fig.tight_layout()
    fig.savefig("{}.svg".format(variable))
    plt.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="compare",
        description="Compare 1D and 3D results",
    )
    parser.add_argument("--o", default="results/1D")
    parser.add_argument("--fa", default=0.25, type=float)
    parser.add_argument("--sigmam", default=20, type=float)
    args = parser.parse_args()

    make_plot(args, "BC_x", "sigma_xx")
