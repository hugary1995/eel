import pandas as pd

currents = ["1e-3", "2e-3", "3e-3"]

for current in currents:
    CC_charging = pd.read_csv("CC_charging_I_"+current+".csv")
    CV_charging = pd.read_csv("CV_charging_I_"+current+".csv")
    CC_discharging = pd.read_csv("CC_discharging_I_"+current+".csv")

    CV_charging["time"] += CC_charging["time"].to_numpy()[-1]
    CC_discharging["time"] += CV_charging["time"].to_numpy()[-1]

    all = pd.concat([CC_charging, CV_charging, CC_discharging])

    all.to_csv("charging_I_"+current+".csv")
