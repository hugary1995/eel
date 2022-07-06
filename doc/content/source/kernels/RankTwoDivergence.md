# RankTwoDivergence

!syntax description /Kernels/RankTwoDivergence

## Overview

Given a strong form $-\divergence \bfA$, the corresponding weak form is

\begin{equation}
  \left( \grad \psi, \bfv \right)_\Omega
\end{equation}

where $\psi$ is the test function, and $\bfv$ is a material property of type `RealVectorValue`.

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Kernels/diffusion+

!syntax parameters /Kernels/RankTwoDivergence

!syntax inputs /Kernels/RankTwoDivergence

!syntax children /Kernels/RankTwoDivergence
