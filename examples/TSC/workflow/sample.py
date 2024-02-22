import numpy as np
from matplotlib import pyplot as plt
import shutil
from pathlib import Path

# Matrix mesh density
RVE_EX = 0.2  # mm
RVE_EY = 0.01  # mm
RVE_EZ = 0.01  # mm

# Fiber length (Gamma)
FIBER_L_loc = 1.5  # mm
FIBER_L_scale = 0.1
FIBER_L_theta = FIBER_L_scale**2 / FIBER_L_loc
FIBER_L_k = FIBER_L_loc / FIBER_L_theta

# Fiber cross-sectional area (Gamma)
FIBER_A_loc = 1.23e-4  # mm
FIBER_A_scale = 2.35e-5
FIBER_A_theta = FIBER_A_scale**2 / FIBER_A_loc
FIBER_A_k = FIBER_A_loc / FIBER_A_theta

# Fiber misalignment angle (Normal)
FIBER_S_loc = 0
FIBER_S_scale = 1 * np.pi / 180

# Fiber misalignment orientation (Uniform)
FIBER_T_a = 0
FIBER_T_b = 2 * np.pi

# Fiber linear mass (Gamma)
FIBER_M_loc = 0.2  # mg/mm
FIBER_M_scale = 0.01
FIBER_M_theta = FIBER_M_scale**2 / FIBER_M_loc
FIBER_M_k = FIBER_M_loc / FIBER_M_theta

# Fiber specific conductivity (Gamma)
FIBER_G_loc = 5100  # S-mm^2/mg
FIBER_G_scale = 300
FIBER_G_theta = FIBER_G_scale**2 / FIBER_G_loc
FIBER_G_k = FIBER_G_loc / FIBER_G_theta


def get_fibers(cx, cy, cz, l, s, t, x, y, z):
    n = len(l)

    # misalignment
    r = np.empty((n, 3))
    r[:, 0] = np.cos(s)
    r[:, 1] = np.sin(t) * np.sin(s)
    r[:, 2] = -np.cos(t) * np.sin(s)
    r /= np.linalg.norm(r, axis=1).reshape((n, 1))

    # positions
    p = np.stack([cx, cy, cz]).T
    p1 = p - l.reshape((n, 1)) / 2 * r
    p2 = p + l.reshape((n, 1)) / 2 * r

    # trim
    p1 = np.clip(p1, [0, 0, 0], [x, y, z])
    p2 = np.clip(p2, [0, 0, 0], [x, y, z])

    return p1, p2


def discard(p1, p2, a, v, vf):
    # compute volume
    v_fiber = np.linalg.norm(p2 - p1, axis=1) * a

    # make sure total fiber volume is greater than v*vf
    assert np.sum(v_fiber) > v * vf

    v_fiber_cum = np.cumsum(v_fiber)
    n = np.argwhere(v_fiber_cum > v * vf)[0, 0]

    return n + 1


def realize(id, RVE_X, RVE_Y, RVE_Z, VF):
    folder = Path("realizations") / str(id)
    if folder.exists():
        shutil.rmtree(folder)
    folder.mkdir(parents=True, exist_ok=True)

    RVE_V = RVE_X * RVE_Y * RVE_Z

    # Sample fiber size
    n = int(2 * RVE_V / FIBER_L_loc / FIBER_A_loc * VF)
    FIBER_L = np.random.gamma(FIBER_L_k, FIBER_L_theta, n)
    FIBER_A = np.random.gamma(FIBER_A_k, FIBER_A_theta, n)

    # Sample fiber position
    FIBER_X = np.random.uniform(0, RVE_X, n)
    FIBER_Y = np.random.uniform(0, RVE_Y, n)
    FIBER_Z = np.random.uniform(0, RVE_Z, n)

    # Sample fiber orientation
    FIBER_S = np.random.normal(FIBER_S_loc, FIBER_S_scale, n)
    FIBER_T = np.random.uniform(FIBER_T_a, FIBER_T_b, n)

    # Sample fiber properties
    FIBER_M = np.random.gamma(FIBER_M_k, FIBER_M_theta, n)
    FIBER_G = np.random.gamma(FIBER_G_k, FIBER_G_theta, n)
    FIBER_Sigma = FIBER_M * FIBER_G / FIBER_A

    # Calculate fiber starting and ending positions
    FIBERs = get_fibers(
        FIBER_X, FIBER_Y, FIBER_Z, FIBER_L, FIBER_S, FIBER_T, RVE_X, RVE_Y, RVE_Z
    )

    # Throw away some fibers to meet the target volume fraction
    n = discard(*FIBERs, FIBER_A, RVE_V, VF)
    FIBER_P1 = FIBERs[0][:n]
    FIBER_P2 = FIBERs[1][:n]
    FIBER_L = np.linalg.norm(FIBER_P2 - FIBER_P1, axis=1)
    FIBER_A = FIBER_A[:n]
    FIBER_S = FIBER_S[:n]
    FIBER_V = FIBER_A * FIBER_L
    FIBER_VF = np.sum(FIBER_V) / RVE_V
    FIBER_Sigma = FIBER_Sigma[:n]
    n = len(FIBER_L)

    # Plot the sampled fiber length
    fig, ax = plt.subplots()
    ax.hist(FIBER_L, 20, histtype="stepfilled", color="tab:gray")
    ax.set_xlabel("Fiber length (mm)")
    ax.set_ylabel("Number of fibers")
    ax.set_xlim(0)
    textstr = "Length = {:.1f} +- {:.2f} mm".format(np.mean(FIBER_L), np.std(FIBER_L))
    props = dict(boxstyle="round", facecolor="wheat", alpha=0.5)
    ax.text(
        0.05,
        0.95,
        textstr,
        transform=ax.transAxes,
        fontsize=12,
        verticalalignment="top",
        bbox=props,
    )
    fig.suptitle("Number of fibers = {}\nVolume fraction = {:.2f}".format(n, FIBER_VF))
    fig.tight_layout()
    fig.savefig(folder / "length.png")
    plt.close()

    # Plot the sampled fiber cross-sectional area
    fig, ax = plt.subplots()
    ax.hist(FIBER_A, 20, histtype="stepfilled", color="tab:gray")
    ax.set_xlabel("Fiber cross-sectional area (mm^2)")
    ax.set_ylabel("Number of fibers")
    ax.set_xlim(0)
    textstr = "Area = {:.1E} +- {:.2E} mm^2".format(np.mean(FIBER_A), np.std(FIBER_A))
    props = dict(boxstyle="round", facecolor="wheat", alpha=0.5)
    ax.text(
        0.05,
        0.95,
        textstr,
        transform=ax.transAxes,
        fontsize=12,
        verticalalignment="top",
        bbox=props,
    )
    fig.suptitle("Number of fibers = {}\nVolume fraction = {:.2f}".format(n, FIBER_VF))
    fig.tight_layout()
    fig.savefig(folder / "area.png")
    plt.close()

    # Plot the sampled fiber misalignment
    fig, ax = plt.subplots()
    ax.hist(FIBER_S * 180 / np.pi, 20, histtype="stepfilled", color="tab:gray")
    ax.set_xlabel("Fiber misalignment (deg)")
    ax.set_ylabel("Number of fibers")
    textstr = "Misalignment = {:.1f} +- {:.2f} deg".format(
        np.mean(FIBER_S * 180 / np.pi),
        np.std(FIBER_S * 180 / np.pi),
    )
    props = dict(boxstyle="round", facecolor="wheat", alpha=0.5)
    ax.text(
        0.05,
        0.95,
        textstr,
        transform=ax.transAxes,
        fontsize=12,
        verticalalignment="top",
        bbox=props,
    )
    fig.suptitle("Number of fibers = {}\nVolume fraction = {:.2f}".format(n, FIBER_VF))
    fig.tight_layout()
    fig.savefig(folder / "misalignment.png")
    plt.close()

    # Plot the sampled electrical conductivity
    fig, ax = plt.subplots()
    ax.hist(FIBER_Sigma, 20, histtype="stepfilled", color="tab:gray")
    ax.set_xlabel("Fiber electrical conductivity (S/mm)")
    ax.set_ylabel("Number of fibers")
    ax.set_xlim(0)
    textstr = "Conductivity = {:.1E} +- {:.2E} S/mm".format(
        np.mean(FIBER_Sigma), np.std(FIBER_Sigma)
    )
    props = dict(boxstyle="round", facecolor="wheat", alpha=0.5)
    ax.text(
        0.05,
        0.95,
        textstr,
        transform=ax.transAxes,
        fontsize=11,
        verticalalignment="top",
        bbox=props,
    )
    fig.suptitle("Number of fibers = {}\nVolume fraction = {:.2f}".format(n, FIBER_VF))
    fig.tight_layout()
    fig.savefig(folder / "conductivity.png")
    plt.close()

    # Save data for meshing and simulation
    with open(folder / "matrix.i", "w") as file:
        file.write(
            "matrix_x = {:.3E}\nmatrix_y = {:.3E}\nmatrix_z = {:.3E}\nmatrix_nx = {}\nmatrix_ny = {}\nmatrix_nz = {}".format(
                RVE_X,
                RVE_Y,
                RVE_Z,
                int(np.ceil(RVE_X / RVE_EX)),
                int(np.ceil(RVE_Y / RVE_EY)),
                int(np.ceil(RVE_Z / RVE_EZ)),
            )
        )
    np.savetxt(folder / "P1.txt", FIBER_P1)
    np.savetxt(folder / "P2.txt", FIBER_P2)
    np.savetxt(folder / "sigma.txt", FIBER_Sigma.T)


if __name__ == "__main__":
    # RVE size (fibers assumed to be roughly aligned in the X direction)
    RVE_X = 5  # mm
    RVE_Y = 0.1  # mm
    RVE_Z = 0.1  # mm

    # Fiber volume fraction
    VF = 0.65

    # Make this reproducible
    np.random.seed(0)

    for i in range(10):
        realize(i, RVE_X, RVE_Y, RVE_Z, VF)
