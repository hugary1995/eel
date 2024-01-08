#!/usr/bin/env python

import argparse
import numpy as np
import subprocess
import shutil
from pathlib import Path


def run(input, BC, dir, spacing):
    command = [
        "mpiexec",
        "-n",
        args.nproc,
        str(Path.home() / "projects" / "eel" / "eel-opt"),
        "-i",
        input,
        BC,
        "fiber_s={:.3E}".format(spacing),
        "Outputs/file_base='{}/{}_spacing_{:.3E}'".format(
            dir, BC.split(".")[0], spacing
        ),
    ]
    print(" ".join(command))
    subprocess.run(
        command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="run_1D",
        description="Run all 1D simulations",
    )
    parser.add_argument("nproc")
    parser.add_argument("-i", default="1D.i")
    parser.add_argument("-o", default="results/1D")
    parser.add_argument("--BC-x", default="BC_x.i")
    parser.add_argument("--spacing-min", default=0, type=float)
    parser.add_argument("--spacing-max", default=0.04, type=float)
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

    for spacing in np.linspace(args.spacing_min, args.spacing_max, args.num_points):
        run(args.i, args.BC_x, dir, spacing)
