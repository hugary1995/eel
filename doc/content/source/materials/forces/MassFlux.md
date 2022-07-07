# MassFlux

!syntax description /Materials/MassFlux

## Overview

The mass flux is defined as
\begin{equation}
  \bfJ_\alpha = \bfJ_\alpha^\text{eq} + \bfJ_\alpha^\text{vis} = \psi_{, \grad c} + \Delta^*_{, \grad \dot{c}},
\end{equation}
where $c$ is the reference concentration density, $\psi$ is the total internal energy density, and $\Delta^*$ is the total dissipation density.

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Materials/mass_flux+

!syntax parameters /Materials/MassFlux

!syntax inputs /Materials/MassFlux

!syntax children /Materials/MassFlux
