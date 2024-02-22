import numpy as np
from matplotlib import pyplot as plt
import shutil
from pathlib import Path
import pandas as pd


def gather_data(path):
    data_x = pd.read_csv(path / "x_out.csv")
    data_y = pd.read_csv(path / "y_out.csv")
    data_z = pd.read_csv(path / "z_out.csv")
    sigma = np.empty((3, 3))

    sigma[0, 0] = data_x["sigma_xx"].iloc[-1]
    sigma[1, 0] = data_x["sigma_yx"].iloc[-1]
    sigma[2, 0] = data_x["sigma_zx"].iloc[-1]

    sigma[0, 1] = data_y["sigma_xy"].iloc[-1]
    sigma[1, 1] = data_y["sigma_yy"].iloc[-1]
    sigma[2, 1] = data_y["sigma_zy"].iloc[-1]

    sigma[0, 2] = data_z["sigma_xz"].iloc[-1]
    sigma[1, 2] = data_z["sigma_yz"].iloc[-1]
    sigma[2, 2] = data_z["sigma_zz"].iloc[-1]

    sigma = (sigma + sigma.T) / 2

    eigvals = np.linalg.eigvals(sigma)

    return {
        "sigma_xx": sigma[0, 0],
        "sigma_xy": sigma[0, 1],
        "sigma_xz": sigma[0, 2],
        "sigma_yx": sigma[1, 0],
        "sigma_yy": sigma[1, 1],
        "sigma_yz": sigma[1, 2],
        "sigma_zx": sigma[2, 0],
        "sigma_zy": sigma[2, 1],
        "sigma_zz": sigma[2, 2],
        "DoA": np.max(eigvals) / np.min(eigvals),
    }


def deposit_data(data, id, row):
    data.setdefault("id", []).append(id)
    for key, val in row.items():
        data.setdefault(key, []).append(val)


if __name__ == "__main__":
    results = Path("results")
    data = {}

    for id in range(10):
        folder = results / str(id)
        if folder.exists():
            row = gather_data(results / str(id))
            deposit_data(data, id, row)

    print(data)
