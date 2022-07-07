# Polarization

!syntax description /Materials/Polarization

## Overview

This material defines the following electrical energy density
\begin{equation}
  \psi^e = \dfrac{1}{2} J \varepsilon_0 \varepsilon_r \bfe \cdot \bfe, \quad \bfe = \bfF^{-T} \grad \Phi,
\end{equation}
where $J$ is the Jacobian of the deformation gradient, $\varepsilon_0$ is the vacuum permittivity, $\varepsilon_r$ is the relative permittivity, and $\bfe$ is the spatial electric field.

Relevant derivatives:
\begin{equation}
  \begin{aligned}
    \psi^e_{,\grad \Phi} &= J \varepsilon_0 \varepsilon_r \bfC^{-1} \grad \Phi, \\
    \psi^e_{,\bfF} &= J \varepsilon_0 \varepsilon_r \left[ \dfrac{1}{2} (\bfe \cdot \bfe) \bfF^{-T} - \bfe \otimes \bfe \right].
  \end{aligned}
\end{equation}

## Example Input File Syntax

!listing tests/electrical/uniform_sphere_charge.i
         block=Materials/polarization

!syntax parameters /Materials/Polarization

!syntax inputs /Materials/Polarization

!syntax children /Materials/Polarization
