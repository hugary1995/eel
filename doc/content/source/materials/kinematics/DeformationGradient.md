# DeformationGradient

!syntax description /Materials/DeformationGradient

## Overview

The total deformation gradient is defined as
\begin{equation}
  \bfF = \bfI + \grad \bfu.
\end{equation}

Multiplicative decomposition is used to model [swelling](SwellingDeformationGradient.md) and [thermal](ThermalDeformationGradient.md) eigenstrains:
\begin{equation}
  \bfF = \bfF^e \bfF^s \bfF^t.
\end{equation}

Note that $\bfF^s$ and $\bfF^t$ are volumetric (diagonal) hence commute. 

Relevant derivatives:
\begin{equation}
  \begin{aligned}
    \bfF^e_{,\bfF} &= \delta_{ik}{F^g}^{-1}_{lj}, \quad F^g_{ij} = F^s_{ik}F^t_{kj}, \\
    \bfF^e_{,\bfF^s} &= -{F^e}_{ik}{F^s}^{-1}_{lj}.
  \end{aligned}
\end{equation}

!syntax parameters /Materials/DeformationGradient

!syntax inputs /Materials/DeformationGradient

!syntax children /Materials/DeformationGradient
