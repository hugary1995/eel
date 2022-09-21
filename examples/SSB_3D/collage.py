import mooseutils
import numpy as np
import cv2
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from pathlib import Path

Path("animation").mkdir(parents=True, exist_ok=True)

# Postprocessor values
frames = 40
data = mooseutils.PostprocessorReader("3D_demo.csv")
C = data["C"].tolist()
V = data["V"].tolist()
dC = max(C) / frames

logo = cv2.imread('gold/anl.png')
logo = cv2.resize(logo, (720, 270))
logo = cv2.copyMakeBorder(logo, 45, 45, 0, 0, cv2.BORDER_REPLICATE)

for step in range(1, frames):
    print("writing step {}".format(step))

    Phi_ca = cv2.imread('Phi_ca/Phi_ca_'+str(step)+'.png')
    Phi = cv2.imread('Phi/Phi_'+str(step)+'.png')
    i_ca = cv2.imread('i_ca/i_ca__'+str(step)+'.png')
    i = cv2.imread('i/i__'+str(step)+'.png')
    c = cv2.imread('c/c_'+str(step)+'.png')
    j = cv2.imread('j/j__'+str(step)+'.png')
    T = cv2.imread('T/T_'+str(step)+'.png')
    h = cv2.imread('h/h__'+str(step)+'.png')
    s = cv2.imread('stress/stress_'+str(step)+'.png')

    fig = Figure(figsize=(6, 6), dpi=120)
    canvas = FigureCanvas(fig)
    ax = fig.gca()
    ax.plot(C, V, 'k-')
    ax.plot([dC*step, dC*step], [0, 6], 'b-')
    ax.set_xlim(0)
    ax.set_ylim(0)
    ax.set_xlabel('Capacity [mA s]')
    ax.set_ylabel('Voltage [V]')
    fig.tight_layout()
    canvas.draw()
    CV = np.frombuffer(canvas.tostring_rgb(), dtype=np.uint8)
    CV = CV.reshape(fig.canvas.get_width_height()[::-1] + (3,))

    row1 = np.concatenate((Phi_ca, i_ca, c), axis=1)
    row2 = np.concatenate((Phi, i, j), axis=1)
    row12 = np.concatenate((row1, row2))
    row12 = np.concatenate((row12, CV), axis=1)
    row3 = np.concatenate((s, T, h, logo), axis=1)
    all = np.concatenate((row12, row3))

    cv2.imwrite('animation/frame_'+f'{step:02}'+'.png', all)
