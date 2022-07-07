# Charging

!syntax description /Materials/Charging

## Overview

The charging energy couples chemical reactions of a charged species to electrostatics. The energy density is defined as

\begin{equation}
  {\psi^c_\alpha}^* = \left( \dfrac{\sigma}{F} \grad \Phi \right) \cdot \left( \Xi_\alpha \grad c_\alpha \right), \quad \Xi_\alpha = \eta_\alpha \Omega_\alpha R T,
\end{equation}

where $\sigma$ is the electric conductivity, $F$ is the Faraday's constant, $\eta_\alpha$ is the mass transport viscosity, $\Omega_\alpha$ is the molar volume of the charged species, $R$ is the ideal gas constant, and $T$ is the temperature.

Relevant derivatives:
\begin{equation}
  \begin{aligned}
    {\psi^c_{\alpha}}^*_{,\grad c_\alpha} &= \Xi_\alpha \dfrac{\sigma}{F} \grad \Phi, \\
    {\psi^c_{\alpha}}^*_{,\grad \Phi} &= \Xi_\alpha \dfrac{\sigma}{F} \grad c_\alpha.
  \end{aligned}
\end{equation}

## Example Input File Syntax

!listing tests/chemical-electrical/base.i
         block=Materials/charging

!syntax parameters /Materials/Charging

!syntax inputs /Materials/Charging

!syntax children /Materials/Charging
