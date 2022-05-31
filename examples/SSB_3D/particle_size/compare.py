# Copyright 2023, UChicago Argonne, LLC All Rights Reserved
# License: L-GPL 3.0
import matplotlib.pyplot as plt
import pandas as pd
import scipy as sp

small = pd.read_csv("0.5-5-10.csv")
medium = pd.read_csv("0.5-10-20.csv")
large = pd.read_csv("0.5-15-30.csv")

fig, ax = plt.subplots()

ax.plot(small["C"], small["V"], label="small")
ax.plot(medium["C"], medium["V"], label="medium")
ax.plot(large["C"], large["V"], label="large")
ax.legend()

plt.show()

print(
    "medium capacity {:.3E}".format(
        sp.interpolate.interp1d(medium["V"], medium["C"])(4.6)
    )
)

print(
    "large capacity {:.3E}".format(sp.interpolate.interp1d(large["V"], large["C"])(4.6))
)
