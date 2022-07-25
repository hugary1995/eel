import vtk
import chigger
import mooseutils
import cv2
import numpy as np


camera = vtk.vtkCamera()
camera.SetViewUp(0, 1, 0)
camera.SetPosition(30, 5, 60)
camera.SetFocalPoint(30, 5, 0)

cb_options = {'precision': 2, 'num_ticks': 3, 'notation': 'fixed'}

# Postprocessor values
data = mooseutils.PostprocessorReader("charging_out.csv")

# Exodus file
ex = chigger.exodus.ExodusReader("charging_out.e")

# Electric field
Phi = chigger.exodus.ExodusResult(ex, variable="Phi", camera=camera, viewport=[
                                  0, 0, 0.5, 0.3], cmap="jet", min=-6.5, max=0)
Phi_cb = chigger.exodus.ExodusColorBar(
    Phi, location="bottom", primary=cb_options)

# Concentration
c = chigger.exodus.ExodusResult(ex, variable="c", camera=camera, viewport=[
                                0.5, 0, 1, 0.3], cmap="jet", min=1e-3, max=4e-3)
c_cb = chigger.exodus.ExodusColorBar(
    c, location="bottom", primary=cb_options)

# Vonmises stress
stress = chigger.exodus.ExodusResult(ex, variable="stress", camera=camera, viewport=[
                                     0, 0.3, 0.5, 0.6], cmap="rainbow", min=0, max=1e4)
stress_cb = chigger.exodus.ExodusColorBar(
    stress, location="bottom", primary=cb_options)

# Temperature
T = chigger.exodus.ExodusResult(ex, variable="T", camera=camera, viewport=[
    0.5, 0.3, 1, 0.6], cmap="jet", min=300, max=333)
T_cb = chigger.exodus.ExodusColorBar(
    T, location="bottom", primary=cb_options)

# Voltage and capacity
C = data["capacity"].tolist()
V = data["voltage"].tolist()
line = chigger.graphs.Line(C, V, width=5, color=[0, 0.5, 0])
tracer_CV = chigger.graphs.Line(color=[1, 0, 0], xtracer=True)
graph_CV = chigger.graphs.Graph(line, tracer_CV, viewport=[0, 0.6, 0.35, 1])
graph_CV.setOptions("xaxis", title="Capacity [mAh]", font_size=15)
graph_CV.setOptions("yaxis", lim=[0, 6.5], title="Voltage [V]", font_size=15)

# Energies
t = data["time"].tolist()
Psi_e = (data["Psi_e"]/max(data["Psi_e"])).tolist()
Psi_c = (data["Psi_c"]/max(data["Psi_c"])).tolist()
Psi_m = (data["Psi_m"]/max(data["Psi_m"])).tolist()
line_e = chigger.graphs.Line(t, Psi_e, width=3, color=[
                             0, 0, 0.5], label="Electrical energy")
line_c = chigger.graphs.Line(t, Psi_c, width=3, color=[
                             252/255, 186/255, 3/255], label="Chemical energy")
line_m = chigger.graphs.Line(t, Psi_m, width=3, color=[
                             3/255, 252/255, 48/255], label="Mechanical energy")
tracer_Psi = chigger.graphs.Line(color=[1, 0, 0], xtracer=True)
graph_Psi = chigger.graphs.Graph(
    line_e, line_c, line_m, tracer_Psi, viewport=[0.4, 0.6, 0.7, 1])
graph_Psi.setOptions("xaxis", title="Time [s]", font_size=15)
graph_Psi.setOptions("yaxis", lim=[0, 1],
                     title="Normalized energy", font_size=15)

# Logo
ANL = chigger.annotations.ImageAnnotation(filename="animation/anl.png", position=[0.99, 0.975],
                                          horizontal_alignment="right", vertical_alignment="top")

# choose codec according to format needed
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
video = cv2.VideoWriter("charging.avi", fourcc, 25, (1200, 800))
window = chigger.RenderWindow(
    Phi, Phi_cb, c, c_cb, stress, stress_cb, T, T_cb, graph_CV, graph_Psi, ANL, size=[1200, 800], test=False)
for i, t in enumerate(ex.getTimes()):
    if i % 2 == 0:
        print("Time step {}".format(i))
        tracer_CV.setOptions(x=[C[i]], y=[0])
        tracer_Psi.setOptions(x=[t], y=[0])
        ex.setOptions(timestep=i)
        img_name = "animation/charging_{:04d}.png".format(i)
        window.write(img_name)
        img = cv2.imread(img_name)
        video.write(img)

cv2.destroyAllWindows()
video.release()
