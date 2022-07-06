# RankOneDivergence

!syntax description /Kernels/RankOneDivergence

## Overview

Given a strong form $-\divergence \bfv$, the corresponding weak form is

\begin{equation}
  \left( \grad \psi, \bfv \right)_\Omega
\end{equation}

where $\psi$ is the test function, and $\bfv$ is a material property of type `RealVectorValue`.

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Kernels/diffusion+

!syntax parameters /Kernels/RankOneDivergence

!syntax inputs /Kernels/RankOneDivergence

!syntax children /Kernels/RankOneDivergence
