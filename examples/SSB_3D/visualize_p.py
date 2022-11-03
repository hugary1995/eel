from paraview.simple import *
import numpy as np
from pathlib import Path
import sys

# Parameters
filename = sys.argv[1]
frames = int(sys.argv[2])
frame_begin = int(sys.argv[3])
outdir = 'p/'
variable = 'p'
variable_name = 'Pressure'
colorbar = 'Blue Orange (divergent)'
disp_magnitude = 10
variable_min = -0.5
variable_max = 0.5
matrix_opacity = 0.75
backface_opacity = 0.75
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
renderView1.AxesGrid.Visibility = 0
renderView1.Update()

layout1 = GetLayout()
layout1.SetSize((W, H))

#######################################################
# Particle
#######################################################
particle = ExodusIIReader(registrationName='particle', FileName=[filename])
particle.ElementBlocks = ['cp']
particle.DisplacementMagnitude = disp_magnitude
Hide(particle, renderView1)

cellDatatoPointData1 = CellDatatoPointData(
    registrationName='CellDatatoPointData1', Input=particle)
Hide(cellDatatoPointData1, renderView1)

temporalInterpolator1 = TemporalInterpolator(
    registrationName='TemporalInterpolator1', Input=cellDatatoPointData1)
temporalInterpolator1.DiscreteTimeStepInterval = particle.TimestepValues[-1] / frames
temporalInterpolator1Display = Show(
    temporalInterpolator1, renderView1, 'UnstructuredGridRepresentation')
temporalInterpolator1Display.Representation = 'Surface'
temporalInterpolator1Display.SetScalarBarVisibility(renderView1, True)
ColorBy(temporalInterpolator1Display, ('POINTS', variable))
temporalInterpolator1Display.RescaleTransferFunctionToDataRange(True, False)


#######################################################
# Matrix
#######################################################
matrix = ExodusIIReader(registrationName='matrix', FileName=[filename])
matrix.ElementBlocks = ['cm', 'e', 'a']
matrix.DisplacementMagnitude = disp_magnitude
Hide(matrix, renderView1)

cellDatatoPointData2 = CellDatatoPointData(
    registrationName='CellDatatoPointData2', Input=matrix)
Hide(cellDatatoPointData2, renderView1)

merged = MergeBlocks(Input=cellDatatoPointData2)
merged.Tolerance = 0.001
Hide(merged, renderView1)

temporalInterpolator2 = TemporalInterpolator(
    registrationName='TemporalInterpolator2', Input=merged)
temporalInterpolator2.DiscreteTimeStepInterval = matrix.TimestepValues[-1] / frames
temporalInterpolator2Display = Show(
    temporalInterpolator2, renderView1, 'UnstructuredGridRepresentation')
temporalInterpolator2Display.Representation = 'Surface'
temporalInterpolator2Display.BackfaceRepresentation = 'Cull Backface'
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
times = np.linspace(0, particle.TimestepValues[-1], frames)
for step in range(frames):
    print('Saving time step {}'.format(step))
    renderView1.ViewTime = times[step]
    renderView1.Update()
    renderView1.Update()
    SaveScreenshot(outdir+variable+"_"+f'{frame_begin+step:03}'+".png", renderView1,
                   ImageResolution=[W, H], TransparentBackground=0, CompressionLevel='0')
