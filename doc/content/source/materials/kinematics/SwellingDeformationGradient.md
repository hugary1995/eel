# SwellingDeformationGradient

!syntax description /Materials/SwellingDeformationGradient

## Overview

Isotropic swelling due to concentration change can be written as:
\begin{equation}
  \bfF^s = (J^s)^{\frac{1}{3}}\bfI, \quad J^s = 1+\beta^s\sum_\alpha \Omega_\alpha(c_\alpha - c_\alpha^0),
\end{equation}
where $\beta^s$ is the swelling coefficient, $\Omega_\alpha$ is the molar volume of the species $\alpha$, $c_alpha$ is the concentration, and $c_\alpha^0$ is the reference concentration associated with zero swelling deformation.

Relevant derivatives
\begin{equation}
  \bfF^s_{,c_\alpha} = \dfrac{1}{3}(J^s)^{-\frac{2}{3}}\beta^s \Omega_\alpha \bfI.
\end{equation}

## Example Input File Syntax

!listing tests/chemical-mechanical/stress_assisted_diffusion.i
        block=Materials/swelling

!syntax parameters /Materials/SwellingDeformationGradient

!syntax inputs /Materials/SwellingDeformationGradient

!syntax children /Materials/SwellingDeformationGradient
