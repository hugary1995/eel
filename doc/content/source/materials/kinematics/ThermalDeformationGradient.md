# ThermalDeformationGradient

!syntax description /Materials/ThermalDeformationGradient

## Overview

The thermal deformation gradient is defined in terms of the instantaneous coefficient of thermal expansion:
\begin{equation}
  \dot{\bfF}^t = (1+\alpha)\dot{T} \bfI,
\end{equation}
where $\alpha$ is the instantaneous coefficient of thermal expansion. The above equation is numerically integrated in time using the mid point rule.

## Example Input File Syntax

!listing tests/chemical-electrical-thermal-mechanical/pressure.i
         block=Materials/thermal_expansion

!syntax parameters /Materials/ThermalDeformationGradient

!syntax inputs /Materials/ThermalDeformationGradient

!syntax children /Materials/ThermalDeformationGradient
