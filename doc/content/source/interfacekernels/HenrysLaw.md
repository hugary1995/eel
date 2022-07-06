# HenrysLaw

!syntax description /InterfaceKernels/HenrysLaw

## Overview

The Henry's law states that the the amount of a dissolved species in a media is proportional to the amount of the species in the other media across the interface. That is

\begin{equation}
    c_a = H c_b,
\end{equation}
where $H$ is the Henry's law constant.

This interface condition is enforced using a penalty approach.

## Example Input File Syntax

!listing tests/chemical/interface_mass_transport.i
         block=InterfaceKernels

!syntax parameters /InterfaceKernels/HenrysLaw

!syntax inputs /InterfaceKernels/HenrysLaw

!syntax children /InterfaceKernels/HenrysLaw
