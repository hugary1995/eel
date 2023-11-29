import argparse
import numpy as np
import subprocess
import shutil
from pathlib import Path


def run(input, dir, ECR):
    command = [
        "mpiexec",
        "-n",
        args.nproc,
        "../../../../eel-opt",
        "-i",
        input,
        "ECR={}".format(ECR),
        "Outputs/file_base='{}/ECR_{}'".format(dir, ECR),
    ]
    print(" ".join(command))
    subprocess.run(
        command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="run_all",
        description="Run all 2D and 3D simulations",
    )
    parser.add_argument("nproc")
    parser.add_argument("--D2-in")
    parser.add_argument("--D3-in")
    parser.add_argument("--D2-out", default="results/2D")
    parser.add_argument("--D3-out", default="results/3D")
    parser.add_argument("--log-ECR-min", default=-6, type=float)
    parser.add_argument("--log-ECR-max", default=2, type=float)
    parser.add_argument("--num-points", default=20, type=int)
    parser.add_argument("--clean", action="store_true")
    args = parser.parse_args()

    dir2 = Path(args.D2_out)
    if dir2.exists() and args.D2_in:
        if args.clean:
            shutil.rmtree(dir2)
        else:
            raise Exception("Output directory {} already exists".format(dir2))

    dir3 = Path(args.D3_out)
    if dir3.exists() and args.D3_in:
        if args.clean:
            shutil.rmtree(dir3)
        else:
            raise Exception("Output directory {} already exists".format(dir3))

    for ECR in np.logspace(args.log_ECR_min, args.log_ECR_max, args.num_points):
        if args.D2_in:
            run(args.D2_in, dir2, ECR)

        if args.D3_in:
            run(args.D3_in, dir3, ECR)
