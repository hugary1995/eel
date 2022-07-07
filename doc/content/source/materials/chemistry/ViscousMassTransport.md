# ViscousMassTransport

!syntax description /Materials/ViscousMassTransport

## Overview

The viscous dissipation during mass transport has the following form
\begin{equation}
  {\psi^c_\alpha}^* = \dfrac{1}{2} \Xi_\alpha \dot{c}_\alpha^2, \quad \Xi_\alpha = \eta_\alpha \Omega_\alpha R T,
\end{equation}
where $\eta_\alpha$ is the viscosity, $\Omega_\alpha$ is the molar volume of the species, $R$ is the ideal gas constant, and $T$ is the temperature.

Relevant derivatives:
\begin{equation}
  {\psi^c_{\alpha}}^*_{,\dot{c}_\alpha} = \Xi_\alpha \dot{c}_\alpha.
\end{equation}

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Materials/viscosity+

!syntax parameters /Materials/ViscousMassTransport

!syntax inputs /Materials/ViscousMassTransport

!syntax children /Materials/ViscousMassTransport
