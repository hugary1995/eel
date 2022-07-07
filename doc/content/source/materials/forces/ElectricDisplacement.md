# ElectricDisplacement

!syntax description /Materials/ElectricDisplacement

## Overview

The electric displacement is defined as
\begin{equation}
  \bfD = \bfD^\text{eq} + \bfD^\text{vis} = \psi_{, \grad \Phi} + \Delta^*_{, \grad \dot{\Phi}},
\end{equation}
where $\Phi$ is the electric potential, $\psi$ is the total internal energy density, and $\Delta^*$ is the total dissipation density.

## Example Input File Syntax

!listing tests/electrical/uniform_sphere_charge.i
         block=Materials/electric_displacement

!syntax parameters /Materials/ElectricDisplacement

!syntax inputs /Materials/ElectricDisplacement

!syntax children /Materials/ElectricDisplacement
