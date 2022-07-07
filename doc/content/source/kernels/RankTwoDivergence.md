# RankTwoDivergence

!syntax description /Kernels/RankTwoDivergence

## Overview

Given a strong form $-\divergence \left( \bfA^T \bfe_i \right)$, the corresponding weak form is

\begin{equation}
  \left( \grad \psi, \bfA^T \bfe_i \right)_\Omega
\end{equation}

where $\psi$ is the test function, $\bfA$ is a material property of type `RankTwoTensor`, and $i$ is the row number of the second order tensor.

## Example Input File Syntax

!listing tests/mechanical/pull.i
         block=Kernels

!syntax parameters /Kernels/RankTwoDivergence

!syntax inputs /Kernels/RankTwoDivergence

!syntax children /Kernels/RankTwoDivergence
