# ButlerVolmerCondition

!syntax description /InterfaceKernels/ButlerVolmerCondition

## Overview

Citing [Wikipedia](https://en.wikipedia.org/wiki/Butler%E2%80%93Volmer_equation):

> In electrochemistry, the Butler–Volmer equation (named after John Alfred Valentine Butler and Max Volmer), also known as Erdey-Grúz–Volmer equation, is one of the most fundamental relationships in electrochemical kinetics. It describes how the electrical current through an electrode depends on the voltage difference between the electrode and the bulk electrolyte for a simple, unimolecular redox reaction, considering that both a cathodic and an anodic reaction occur on the same electrode.

The specific form of the Butler-Volmer equation implemented in this kernel is

\begin{equation}
    \sigma \grad \Phi \cdot \bfn = i_0 \left[ \exp\left( \dfrac{\alpha_a F}{RT} \eta \right) - \exp\left( -\dfrac{\alpha_c F}{RT} \eta \right) \right], \quad \eta = \Phi_\text{eletrode} - \Phi_\text{eletrolyte},
\end{equation}

where $\sigma$ is the electric conductivity, $\Phi$ is the electric potential, $i_0$ is the reference exchange current density, $\alpha_a$ is the anodic charge transfer coefficient, $\alpha_c$ is the cathodic charge transfer coefficient, $F$ is the Faraday's constant, $R$ is the ideal gas constant, $T$ is the temperature, and $\eta$ is the surface over potential.

This interface condition is enforced using a penalty approach.

## Example Input File Syntax

!listing tests/electrical/redox.i
         block=InterfaceKernels

!syntax parameters /InterfaceKernels/ButlerVolmerCondition

!syntax inputs /InterfaceKernels/ButlerVolmerCondition

!syntax children /InterfaceKernels/ButlerVolmerCondition
