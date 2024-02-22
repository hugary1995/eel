import gmsh
from pathlib import Path
import numpy as np
import math


def generate_fiber_mesh(id):
    gmsh.initialize()

    folder = Path("realizations") / str(id)
    nelem = 10

    # Fiber starting and ending points
    P1 = np.loadtxt(folder / "P1.txt")
    P2 = np.loadtxt(folder / "P2.txt")

    # Get RVE size
    with open(folder / "matrix.i", "r") as file:
        lines = file.readlines()
        matrix_x = float(lines[0].split(" = ")[1])
        matrix_y = float(lines[1].split(" = ")[1])
        matrix_z = float(lines[2].split(" = ")[1])

    # Number of fibers
    assert len(P1) == len(P2)
    n = len(P1)

    # Add fiber geometries
    ltags = np.empty(n, dtype=int)
    p1tags = np.empty(n, dtype=int)
    p2tags = np.empty(n, dtype=int)
    for i in range(n):
        p1tags[i] = gmsh.model.geo.addPoint(*P1[i])
        p2tags[i] = gmsh.model.geo.addPoint(*P2[i])
        ltags[i] = gmsh.model.geo.addLine(p1tags[i], p2tags[i])
        gmsh.model.geo.mesh.setTransfiniteCurve(ltags[i], nelem + 1)

    # Set physical groups
    p1_assigned = np.full(n, False)
    p2_assigned = np.full(n, False)
    left_tags = []
    right_tags = []
    bottom_tags = []
    top_tags = []
    back_tags = []
    front_tags = []
    for i in range(n):
        gmsh.model.geo.addPhysicalGroup(1, [ltags[i]], tag=ltags[i])

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 0], 0):
            left_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 0], 0):
            left_tags.append(p2tags[i])
            p2_assigned[i] = True

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 0], matrix_x):
            right_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 0], matrix_x):
            right_tags.append(p2tags[i])
            p2_assigned[i] = True

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 1], 0):
            bottom_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 1], 0):
            bottom_tags.append(p2tags[i])
            p2_assigned[i] = True

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 1], matrix_y):
            top_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 1], matrix_y):
            top_tags.append(p2tags[i])
            p2_assigned[i] = True

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 2], 0):
            back_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 2], 0):
            back_tags.append(p2tags[i])
            p2_assigned[i] = True

    for i in range(n):
        if not p1_assigned[i] and math.isclose(P1[i, 2], matrix_z):
            front_tags.append(p1tags[i])
            p1_assigned[i] = True
        elif not p2_assigned[i] and math.isclose(P2[i, 2], matrix_z):
            front_tags.append(p2tags[i])
            p2_assigned[i] = True

    gmsh.model.geo.addPhysicalGroup(0, left_tags, name="fiber_left")
    gmsh.model.geo.addPhysicalGroup(0, right_tags, name="fiber_right")
    gmsh.model.geo.addPhysicalGroup(0, bottom_tags, name="fiber_bottom")
    gmsh.model.geo.addPhysicalGroup(0, top_tags, name="fiber_top")
    gmsh.model.geo.addPhysicalGroup(0, back_tags, name="fiber_back")
    gmsh.model.geo.addPhysicalGroup(0, front_tags, name="fiber_front")

    # Write mesh
    gmsh.model.geo.synchronize()
    gmsh.model.mesh.generate()
    gmsh.write(str(folder / "fiber.msh".format(dir)))
    gmsh.finalize()

    # Write fiber subdomains
    with open(folder / "fibers.i", "w") as file:
        file.write("fibers = '{}'\n".format(" ".join(str(ltag) for ltag in ltags)))
        file.write("fiber_mesh = '{}'".format((folder / "fiber.msh").resolve()))


if __name__ == "__main__":
    for i in range(10):
        generate_fiber_mesh(i)
