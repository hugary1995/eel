import mooseutils
import numpy as np
import cv2
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from pathlib import Path

Path("animation").mkdir(parents=True, exist_ok=True)

# Postprocessor values
frames = 300

for step in range(frames):
    print("writing step {}".format(step))

    Phi_ca = cv2.imread('Phi_ca/Phi_ca_'+f'{step:03}'+'.png')
    Phi = cv2.imread('Phi/Phi_'+f'{step:03}'+'.png')
    i_ca = cv2.imread('i_ca/i_ca__'+f'{step:03}'+'.png')
    i = cv2.imread('i/i__'+f'{step:03}'+'.png')
    c = cv2.imread('c/c_'+f'{step:03}'+'.png')
    j = cv2.imread('j/j__'+f'{step:03}'+'.png')
    T = cv2.imread('T/T_'+f'{step:03}'+'.png')
    h = cv2.imread('h/h__'+f'{step:03}'+'.png')
    s = cv2.imread('p/p_'+f'{step:03}'+'.png')
    CV = cv2.imread('curves/CV_'+f'{step:03}'+'.png')
    Ct = cv2.imread('curves/C_'+f'{step:03}'+'.png')
    Vt = cv2.imread('curves/V_'+f'{step:03}'+'.png')

    row1 = np.concatenate((Phi_ca, i_ca, c, CV), axis=1)
    row2 = np.concatenate((Phi, i, j, Vt), axis=1)
    row3 = np.concatenate((s, T, h, Ct), axis=1)
    all = np.concatenate((row1, row2, row3))

    cv2.imwrite('animation/frame_'+f'{step:03}'+'.png', all)
