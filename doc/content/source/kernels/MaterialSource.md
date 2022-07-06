# MaterialSource

!syntax description /Kernels/MaterialSource

## Overview

This kernel implements the following weak form.

\begin{equation}
  \left( \psi, s \right)_\Omega
\end{equation}
where $\psi$ is the test function, and $s$ the source defined by a material property.

## Example Input File Syntax

!listing tests/chemical/mixing.i
         block=Kernels/source+

!syntax parameters /Kernels/MaterialSource

!syntax inputs /Kernels/MaterialSource

!syntax children /Kernels/MaterialSource
