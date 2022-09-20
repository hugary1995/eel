from paraview.simple import *
import numpy as np
from pathlib import Path

# Parameters
filename = '3D_demo.e'
outdir = 'Phi/'
variable = 'Phi'
variable_name = 'Electric potential'
colorbar = 'Jet'
disp_magnitude = 10
variable_min = -5.59
variable_max = 0.18
matrix_opacity = 0.75
backface_opacity = 0.75
frames = 40
W = 720
H = 360
cbar_location = [0.8, 0.25]
cbar_length = 0.5

paraview.simple._DisableFirstRenderCameraReset()

renderView1 = GetActiveViewOrCreate('RenderView')
renderView1.ResetCamera()
renderView1.OrientationAxesVisibility = 0
renderView1.CameraPosition = [0.18, 0.1, 0.17]
renderView1.CameraFocalPoint = [0.08, 0.014, 0.015]
renderView1.CameraViewUp = [-0.16, 0.90, -0.4]
renderView1.UseLight = 0
renderView1.Update()

layout1 = GetLayout()
layout1.SetSize((W, H))

#######################################################
# Matrix
#######################################################
matrix = ExodusIIReader(registrationName='matrix', FileName=[filename])
matrix.ElementBlocks = ['cm', 'e', 'a']
matrix.DisplacementMagnitude = disp_magnitude

temporalInterpolator2 = TemporalInterpolator(
    registrationName='TemporalInterpolator2', Input=matrix)
temporalInterpolator2.DiscreteTimeStepInterval = matrix.TimestepValues[-1] / frames
temporalInterpolator2Display = Show(
    temporalInterpolator2, renderView1, 'UnstructuredGridRepresentation')
temporalInterpolator2Display.Representation = 'Surface'
temporalInterpolator2Display.BackfaceRepresentation = 'Surface'
temporalInterpolator2Display.BackfaceOpacity = backface_opacity
temporalInterpolator2Display.Opacity = matrix_opacity
temporalInterpolator2Display.SetScalarBarVisibility(renderView1, True)
ColorBy(temporalInterpolator2Display, ('POINTS', variable))
temporalInterpolator2Display.RescaleTransferFunctionToDataRange(True, False)
temporalInterpolator2Display.SetScalarBarVisibility(renderView1, True)

#######################################################
# Colorbar
#######################################################
tLUT = GetColorTransferFunction(variable)
tLUT.RescaleTransferFunction(variable_min, variable_max)
tLUT.ApplyPreset(colorbar, True)
tLUTColorBar = GetScalarBar(tLUT, renderView1)
tLUTColorBar.WindowLocation = 'AnyLocation'
tLUTColorBar.Position = cbar_location
tLUTColorBar.ScalarBarLength = cbar_length
tLUTColorBar.AddRangeLabels = 0
tLUTColorBar.Title = variable_name


#######################################################
# Animation
#######################################################
Path(outdir).mkdir(parents=True, exist_ok=True)
times = np.linspace(0, matrix.TimestepValues[-1], frames)
for step in range(frames):
    print('Saving time step {}'.format(step))
    renderView1.ViewTime = times[step]
    renderView1.Update()
    renderView1.Update()
    SaveScreenshot(outdir+variable+"_"+str(step)+".png", renderView1,
                   ImageResolution=[W, H], TransparentBackground=0, CompressionLevel='0')
