from paraview.simple import *
import numpy as np

# Parameters
filename = '3D_demo.e'
outdir = 'c/'
variable = 'c'
variable_name = 'Concentration'
colorbar = 'Rainbow Uniform'
disp_magnitude = 10
variable_min = 1e-4
variable_max = 1e-3
matrix_opacity = 0.75
frames = 40
W = 720
H = 360

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
layout1.SetSize(W, H)

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

matrix_display = GetDisplayProperties(matrix, view=renderView1)
matrix_display.Representation = 'Feature Edges'
matrix_display.AmbientColor = [0.0, 0.0, 0.0]
matrix_display.DiffuseColor = [0.0, 0.0, 0.0]

#######################################################
# Colorbar
#######################################################
tLUT = GetColorTransferFunction(variable)
tLUT.ApplyPreset(colorbar, True)
tLUT.RescaleTransferFunction(variable_min, variable_max)
tLUTColorBar = GetScalarBar(tLUT, renderView1)
tLUTColorBar.WindowLocation = 'AnyLocation'
tLUTColorBar.Position = [0.85, 0.25]
tLUTColorBar.ScalarBarLength = 0.5
tLUTColorBar.AddRangeLabels = 0
tLUTColorBar.Title = variable_name
tLUTColorBar.ComponentTitle = ''
tLUTColorBar.HorizontalTitle = 1


#######################################################
# Animation
#######################################################
times = np.linspace(0, particle.TimestepValues[-1], frames)
for step in range(frames):
    print('Saving time step {}'.format(step))
    renderView1.ViewTime = times[step]
    renderView1.Update()
    # temporalInterpolator1Display.RescaleTransferFunctionToDataRange(
    #     False, True)
    renderView1.Update()
    SaveScreenshot(outdir+variable+"_"+str(step)+".png", renderView1,
                   ImageResolution=[W, H], TransparentBackground=0, CompressionLevel='0')
