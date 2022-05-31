# NeoHookeanSolid

!syntax description /Materials/NeoHookeanSolid

## Overview

This material defines the following mechanical energy density of Neo-Hookean type:
\begin{equation}
  \psi^m = \dfrac{1}{2} \lambda \ln^2(I_3) + \dfrac{1}{2} G\left[ I_1 - 2\ln(I_3) - 3 \right], \quad I_1 = \text{tr}\left( {F^e}^T F^e \right), \quad I_3 = \det\left( F^e \right),
\end{equation}
where $\lambda$ and $G$ are Lame parameters, $I_1$ and $I_3$ are invariants of the right Cauchy Green strain.

Relevant derivatives:
\begin{equation}
  \begin{aligned}
    \psi^m_{,\bfF^e} &= \lambda \ln(I_3) {\bfF^e}^{-T} + G \left( \bfF^e - {\bfF^e}^{-T} \right), \\
    \psi^m_{,\bfF} &= \psi^m_{,\bfF^e} : \bfF^e_{,\bfF}, \\
    \psi^m_{,c} &= \psi^m_{,\bfF^e} : \bfF^e_{,\bfF^s} : \bfF^s_{,c_\alpha}.
  \end{aligned}
\end{equation}

## Example Input File Syntax

!listing tests/chemical-mechanical/stress_assisted_diffusion.i
         block=Materials/neohookean

!syntax parameters /Materials/NeoHookeanSolid

!syntax inputs /Materials/NeoHookeanSolid

!syntax children /Materials/NeoHookeanSolid
