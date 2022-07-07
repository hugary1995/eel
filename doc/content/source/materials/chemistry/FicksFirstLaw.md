# FicksFirstLaw

!syntax description /Materials/FicksFirstLaw

## Overview

The Fick's first law is defined by the following chemical energy density:
\begin{equation}
  \psi^c_\alpha = \dfrac{1}{2} \Xi_\alpha D_\alpha \grad c_\alpha \cdot \grad c_\alpha, \quad \Xi_\alpha = \eta_\alpha \Omega_\alpha R T,
\end{equation}
where $\eta_\alpha$ is the mass transport viscosity, $\Omega_\alpha$ is the molar volume of this chemical species, $R$ is the ideal gas constant, $T$ is the temperature, $\bfD_\alpha$ is the diffusion coefficient, and $c_\alpha$ is the reference concentration density.

Relevant derivatives:
\begin{equation}
  {\psi^c_{\alpha}}^*_{,\grad \dot{c}_\alpha} = \Xi_\alpha \bfD \grad \Phi.
\end{equation}

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Materials/fick+

!syntax parameters /Materials/FicksFirstLaw

!syntax inputs /Materials/FicksFirstLaw

!syntax children /Materials/FicksFirstLaw
