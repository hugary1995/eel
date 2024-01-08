#!/usr/bin/env python

import argparse
import numpy as np
import subprocess
import shutil
from pathlib import Path
import pandas as pd


def run(input, BC, dir):
    command = [
        "mpiexec",
        "-n",
        args.nproc,
        str(Path.home() / "projects" / "eel" / "eel-opt"),
        "-i",
        input,
        BC,
        "Outputs/file_base='{}/{}'".format(dir, BC.split(".")[0]),
    ]
    print(" ".join(command))
    subprocess.run(
        command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="run_3D",
        description="Run all 3D simulations",
    )
    parser.add_argument("nproc")
    parser.add_argument("-i", default="3D.i")
    parser.add_argument("-o", default="results/3D")
    parser.add_argument("--BC-x", default="BC_x.i")
    parser.add_argument("--BC-y", default="BC_y.i")
    parser.add_argument("--BC-z", default="BC_z.i")
    parser.add_argument("--log-ECR-min", default=-6, type=float)
    parser.add_argument("--log-ECR-max", default=2, type=float)
    parser.add_argument("--num-points", default=20, type=int)
    parser.add_argument("--clean", action="store_true")
    args = parser.parse_args()

    dir = Path(args.o)
    if dir.exists():
        if args.clean:
            shutil.rmtree(dir)
        else:
            raise Exception(
                "Output directory {} already exists. "
                "Use --clean to remove the existing directory.".format(dir)
            )

    ECRs = np.logspace(args.log_ECR_min, args.log_ECR_max, args.num_points)
    df = pd.DataFrame({"x": np.arange(args.num_points + 1), "y": np.insert(ECRs, 0, 0)})
    df.to_csv("ECR_3D.csv", index=False)

    run(args.i, args.BC_x, dir)
    run(args.i, args.BC_y, dir)
    run(args.i, args.BC_z, dir)
