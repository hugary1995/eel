import mooseutils
import numpy as np
import cv2
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure

# Postprocessor values
frames = 40
data = mooseutils.PostprocessorReader("3D_demo.csv")
C = data["C"].tolist()
V = data["V"].tolist()
dC = max(C) / frames

logo = cv2.imread('anl.png')
logo = cv2.resize(logo, (480, 168))
logo = cv2.copyMakeBorder(logo, 240-168, 0, 0, 0, cv2.BORDER_REPLICATE)

for step in range(1, frames):
    print("writing step {}".format(step))

    Phi_c = cv2.imread('Phi_c/Phi_'+str(step)+'.png')
    Phi = cv2.imread('Phi/Phi_'+str(step)+'.png')
    c = cv2.imread('c/c_'+str(step)+'.png')
    T = cv2.imread('T/T_'+str(step)+'.png')
    u = cv2.imread('disp/disp__'+str(step)+'.png')
    s = cv2.imread('stress/stress_'+str(step)+'.png')

    row1 = np.concatenate((Phi_c, Phi), axis=1)
    row2 = np.concatenate((c, T), axis=1)
    row3 = np.concatenate((u, s), axis=1)
    all = np.concatenate((row1, row2, row3))

    fig = Figure(figsize=(4, 7), dpi=120)
    canvas = FigureCanvas(fig)
    ax = fig.gca()
    ax.plot(C, V, 'k-')
    ax.plot([dC*step, dC*step], [0, 6], 'b-')
    ax.set_xlim(0)
    ax.set_ylim(0)
    ax.set_xlabel('Capacity [mA s]')
    ax.set_ylabel('Voltage [V]')
    fig.tight_layout(pad=0)
    canvas.draw()
    CV = np.frombuffer(canvas.tostring_rgb(), dtype=np.uint8)
    CV = CV.reshape(fig.canvas.get_width_height()[::-1] + (3,))
    CV = np.concatenate((CV, logo))

    all = np.concatenate((all, CV), axis=1)
    cv2.imwrite('animation/frame_'+f'{step:02}'+'.png', all)
