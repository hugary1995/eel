import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


n_cycle = 30

max_C = []

fig, (ax1, ax2) = plt.subplots(1, 2)

for cycle in range(1, n_cycle+1):
    CC_charging = pd.read_csv("cycle_"+str(cycle)+"_CC_charging_I_3e-3.csv")
    CV_charging = pd.read_csv("cycle_"+str(cycle)+"_CV_charging_I_3e-3.csv")
    CC_discharging = pd.read_csv(
        "cycle_"+str(cycle)+"_CC_discharging_I_3e-3.csv")
    C = np.concatenate(
        (CC_charging["C"], CV_charging["C"], CC_discharging["C"]))
    V = np.concatenate(
        (CC_charging["V"], CV_charging["V"], CC_discharging["V"]))
    ax1.plot(C, V, label="cycle "+str(cycle))

    max_C.append(CV_charging["C"].to_numpy()[-1])

ax1.set_xlabel("C (mA s)")
ax1.set_ylabel("V (volt)")
ax1.legend()

ax2.plot(max_C, 'ko-')
ax2.set_xlabel("cycle")
ax2.set_ylabel("C (mA s)")

plt.show()
