#!/usr/bin/env python

import argparse
import pandas as pd
from pathlib import Path
from matplotlib import pyplot as plt
import numpy as np


def make_plot(args, BC, variable):
    fig, ax = plt.subplots()

    if args.o1:
        dir = Path(args.o1)
        ECR = pd.read_csv("ECR_1D.csv")
        res = pd.read_csv(dir / "{}.csv".format(BC))
        ax.plot(ECR["y"], res[variable], "r.-", label="1D")

    if args.o3:
        dir = Path(args.o3)
        ECR = pd.read_csv("ECR_3D.csv")
        res = pd.read_csv(dir / "{}.csv".format(BC))
        ax.plot(ECR["y"], res[variable], "k-", label="3D")

    ax.set_xlabel("Electrical contact resistance")
    ax.set_ylabel("Homogenized electrical conductivity")
    ax.set_xscale("log")
    ax.set_ylim(args.ymin, args.ymax)
    ax.legend()
    fig.tight_layout()
    fig.savefig("{}.svg".format(variable))
    plt.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="compare",
        description="Compare 1D and 3D results",
    )
    parser.add_argument("--o1")
    parser.add_argument("--o3")
    parser.add_argument("--ymin", default=19, type=float)
    parser.add_argument("--ymax", default=23, type=float)
    args = parser.parse_args()

    make_plot(args, "BC_x", "sigma_xx")
    make_plot(args, "BC_y", "sigma_yy")
    make_plot(args, "BC_z", "sigma_zz")
