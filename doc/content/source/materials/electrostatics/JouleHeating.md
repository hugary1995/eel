# JouleHeating

!syntax description /Materials/JouleHeating

## Overview

The underlying potential for Joule heating can be written as
\begin{equation}
  \chi = \sigma \grad \Phi \cdot \grad \Phi \ln\left( \dfrac{T}{T^\text{eq}} \right)
\end{equation}
where $\sigma$ is the electric conductivity, $\Phi$ is the electric potential, and $T$ is the temperature.

At equilibrium, the corresponding heat source is given as
\begin{equation}
  q = \sigma \grad \Phi \cdot \grad \Phi,
\end{equation}
which is analogous to the macroscopic $I^2 R$ heating associated with current flow through a resistor.

## Example Input File Syntax

!listing tests/chemical-electrical-thermal/base.i
         block=Materials/joule_heating

!syntax parameters /Materials/JouleHeating

!syntax inputs /Materials/JouleHeating

!syntax children /Materials/JouleHeating
