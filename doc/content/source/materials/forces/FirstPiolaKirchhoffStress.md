# FirstPiolaKirchhoffStress

!syntax description /Materials/FirstPiolaKirchhoffStress

## Overview

The first Piola-Kirchhoff stress is defined as
\begin{equation}
  \bfP = \bfP^\text{eq} + \bfP^\text{vis} = \psi_{, \bfF} + \Delta^*_{, \dot{\bfF}},
\end{equation}
where $\bfF$ is the deformation gradient, $\psi$ is the total internal energy density, and $\Delta^*$ is the total dissipation density.

## Example Input File Syntax

!listing tests/mechanical/swelling.i
         block=Materials/pk1_stress

!syntax parameters /Materials/FirstPiolaKirchhoffStress

!syntax inputs /Materials/FirstPiolaKirchhoffStress

!syntax children /Materials/FirstPiolaKirchhoffStress
