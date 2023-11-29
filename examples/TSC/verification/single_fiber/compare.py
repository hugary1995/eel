import argparse
import pandas as pd
from pathlib import Path
from matplotlib import pyplot as plt
import numpy as np


def get_results(dir, pattern, name):
    ECRs = []
    sigmas = []
    for file in dir.glob(pattern):
        data = pd.read_csv(file)
        ECR = float(file.stem.split("_")[2])
        sigma = data[name].iloc[-1]
        ECRs.append(ECR)
        sigmas.append(sigma)
    ECRs = np.array(ECRs)
    sigmas = np.array(sigmas)
    idx = np.argsort(ECRs)
    return ECRs[idx], sigmas[idx]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="compare",
        description="Compare 2D and 3D results",
    )
    parser.add_argument("dir")
    parser.add_argument("-v", "--variable", default="sigma_yy")
    args = parser.parse_args()
    dir = Path(args.dir)

    ECR_2D, sigma_2D = get_results(dir, "2D_*.csv", args.variable)
    ECR_3D, sigma_3D = get_results(dir, "3D_*.csv", args.variable)

    fig, ax = plt.subplots()
    ax.plot(ECR_3D, sigma_3D, "k*", label="3D")
    ax.plot(ECR_2D, sigma_2D, "ro-", label="2D")
    ax.set_xlabel("Electrical contact resistance")
    ax.set_ylabel("Homogenized electrical conductivity")
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.legend()
    fig.tight_layout()
    fig.savefig("comparison.png")
