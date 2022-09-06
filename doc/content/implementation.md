# Implementation

The [variational statement](theory.md) of the problem not only is consistent with thermodynamics, but also provides a generic interface for programming.

Following [the theory manual](theory.md), the implementation can be natually divided into three categories:

- Constitutive models, i.e. the definitions of the internal energy densities and dissipation densities.
- Thermodynamic forces, i.e. the thermodynamic conjugate of the generalized velocities.
- Weak form of the balance laws.

## Constitutive models

- Chemical reactions

  - [Fick's first law](FicksFirstLaw.md)
  - [Viscous mass transport](ViscousMassTransport.md)
  - [Transport of charged species](Charging.md)

- Electrostatics

  - [Polarization](Polarization.md)
  - [Heat generation due to Joule heating](JouleHeating.md)

- Mechanics

  - [Deformation gradient](DeformationGradient.md)
  - [Swelling](SwellingDeformationGradient.md)
  - [Thermal expansion](ThermalDeformationGradient.md)
  - [A Neo-Hookean strain energy density](NeoHookeanElasticEnergyDensity.md)

## Thermodynamic forces

Recall that the thermodynamic forces are defined as
\begin{equation}
  \mathcal{F} = \{ \bfP, \mu_\alpha, \bfJ_\alpha, \bfD \},
\end{equation}
with constitutive relations (from Coleman-Noll)
\begin{equation}
  \begin{aligned}
    & \bfP = \bfP^\text{eq}+\bfP^\text{vis}, \quad \mu_\alpha = \mu^\text{eq}_\alpha+\mu^\text{vis}_\alpha, \quad \bfJ_\alpha = \bfJ^\text{eq}_\alpha+\bfJ^\text{vis}_\alpha, \quad \bfD = \bfD^\text{eq}+\bfD^\text{vis}, \\
    & \bfP^\text{eq} = \psi_{,\bfF}, \quad \mu^\text{eq}_\alpha = \psi_{,c_\alpha}, \quad \bfJ^\text{eq}_\alpha = \psi_{,\grad c_\alpha}, \quad \bfD^\text{eq} = \psi_{,\grad \Phi}, \\
    & \bfP^\text{vis} = \Delta^*_{,\dot{\bfF}}, \quad \mu^\text{vis}_\alpha = \Delta^*_{,\dot{c}_\alpha}, \quad \bfJ^\text{vis}_\alpha = \Delta^*_{,\grad \dot{c}_\alpha}, \quad \bfD^\text{vis} = \Delta^*_{,\grad \dot{\Phi}}.
  \end{aligned}
\end{equation}

In Eel, the forces are automaticall calculated using the above definitions relying on the [derivative material interface](https://mooseframework.inl.gov/source/materials/DerivativeMaterialInterface.html).

- [`FirstPiolaKirchhoffStress`](FirstPiolaKirchhoffStress.md) computes the first Piola-Kirchhoff stress $\bfP$.
- [`MassSource`](MassSource.md) computes the chemical source $\mu_\alpha$.
- [`MassFlux`](MassFlux.md) computes the chemical flux $\bfJ_\alpha$.
- [`ElectricDisplacement`](ElectricDisplacement.md) computes the electric displacement $\bfD$.

## Balance laws

The MOOSE framework encourages modular implementation to maximize code reusability. All discretized weak forms of the following governing equations

\begin{equation}
  \begin{aligned}
    -\divergence \bfP - \bfb &= \bs{0}, \\
    -\divergence \bfJ_\alpha + \mu_\alpha &= 0, \\
    -\divergence \bfD + \rho_q &= 0, \\
    -\divergence \bfh + q + \delta + \delta_T &= \rho c_v \dot{T},
  \end{aligned}
\end{equation}

can be implemented using the following reusable kernels.

| Term | Kernel |
| - | :- |
| $-\divergence \bfP$ | [`RankTwoDivergence`](RankTwoDivergence.md) |
| $-\bfb$ | [`MaterialSource`](MaterialSource.md) |
| $-\divergence \bfJ_\alpha$ | [`RankOneDivergence`](RankOneDivergence.md) |
| $\mu_\alpha$ | [`MaterialSource`](MaterialSource.md) |
| $-\divergence \bfD$ | [`RankOneDivergence`](RankOneDivergence.md) |
| $\rho_q$ | [`MaterialSource`](MaterialSource.md) |
| $-\divergence \bfh$ | [`ADHeatConduction`](ADHeatConduction.md) |
| $q$ | [`MaterialSource`](MaterialSource.md) |
| $\delta$ | [`MaterialSource`](MaterialSource.md) |
| $\delta_T$ | [`MaterialSource`](MaterialSource.md) |
| $\rho c_v \dot{T}$ | [`ADHeatConductionTimeDerivative`](ADHeatConductionTimeDerivative.md) |
