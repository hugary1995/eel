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
        ECR = float(file.stem.split("_")[1])
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
    parser.add_argument("--D2-out")
    parser.add_argument("--D3-out")
    parser.add_argument("-v", "--variable", default="sigma_yy")
    args = parser.parse_args()

    fig, ax = plt.subplots()

    if args.D2_out:
        dir = Path(args.D2_out)
        ECR, sigma = get_results(dir, "*.csv", args.variable)
        ax.plot(ECR, sigma, "r.-", label="2D")

    if args.D3_out:
        dir = Path(args.D3_out)
        ECR, sigma = get_results(dir, "*.csv", args.variable)
        ax.plot(ECR, sigma, "k*", label="3D")

    ax.set_xlabel("Electrical contact resistance")
    ax.set_ylabel("Homogenized electrical conductivity")
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.legend()
    fig.tight_layout()
    fig.savefig("comparison.png")
