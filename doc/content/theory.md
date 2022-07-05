# Theory

We construct a potential such that all the thermodynamic equations of state can be derived from a minimization problem.

## Variables

We consider the following variables

\begin{equation}
  \mathcal{S} = \left\{ \bs{\varphi}, c_\alpha, \Phi, T \right\}
\end{equation}

and their generalized velocities

\begin{equation}
  \mathcal{V} = \left\{ \dot{\bs{\varphi}}, \dot{\bfF}, \dot{c}, \grad \dot{c}, \dot{\Phi}, \grad \dot{\Phi} \right\}.
\end{equation}

where

- $\bs{\varphi}$ is the deformation map,
- $c_\alpha$ is the concentration of (charged) species $\alpha = 1...N_s$,
- $\Phi$ is the electric potential, and 
- $T$ is the temperature.

## Potential

We write the total potential in rate form to incorporate dissipative mechanisms:
\begin{equation}
	\begin{aligned}
    \dot{\Pi} &= \int\limits_\Omega \left( \dot{\psi} + \Delta^* - T\dot{s} - \chi \right) \diff{V} - \mathcal{P}, \\
    \psi &= \psi^m(\bfF, c_\alpha) + \sum_\alpha \psi^c_\alpha(\bfF, c_\alpha, \grad c_\alpha) + \psi^e(\bfF, \grad \Phi), \\
    \Delta^* &= {\psi^m}^*\left( \dfrac{T}{T^\text{eq}}\dot{\bfF} \right) + \sum_\alpha {\psi^c_\alpha}^*\left( \dfrac{T}{T^\text{eq}}\dot{c}_\alpha, \dfrac{T}{T^\text{eq}}\grad\dot{c}_\alpha \right) + {\psi^e}^*\left( \dfrac{T}{T^\text{eq}}\grad \dot{\Phi} \right), \\
    \chi &= \dfrac{1}{2}\kappa \dfrac{\grad T}{T}\cdot\dfrac{\grad T}{T}.
  \end{aligned}
\end{equation}

- $\psi$ is the internal energy, which can be additively decomposed into 

  - the mechanical energy $\psi^m$,
  - the chemical energy $\psi^c_\alpha$, and
  - the electrical energy $\psi^e$.

- $\Delta^*$ is the dissipation.
- $s$ is the entropy.
- $\chi$ is the Fourier potential characterizing heat conduction.
- $\mathcal{P}$ is the external power expenditure.

## Governing equations

Denote thermodynamic forces as
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
Balance laws follow from the variational principal, i.e. minimizing the total potential with respect to the generalied velocities and maximizing the total potential with respect to the temperature:
\begin{equation}
  \begin{aligned}
    -\divergence \bfP - \bfb &= \bs{0}, \\
    -\divergence \bfJ_\alpha + \mu_\alpha &= 0, \\
    -\divergence \bfD + \rho_q &= 0, \\
    -\divergence \bfh + q + \delta + \delta_T &= \rho c_v \dot{T},
  \end{aligned}
\end{equation}
where
\begin{equation}
  \begin{aligned}
    \bfh &= -\kappa \grad T, \\
    \delta &= \bfP^\text{vis} : \dot{\bfF} + \mu^\text{vis}_\alpha \dot{c}_\alpha + \bfJ^\text{vis}_\alpha \cdot \grad \dot{c}_\alpha + \bfD^\text{vis} \cdot \grad \dot{\Phi}, \\
    \delta_T &= T\left( \bfP^\text{eq}_{,T} : \dot{\bfF} + \mu^\text{eq}_{\alpha,T} \dot{c}_\alpha + \bfJ^\text{eq}_{\alpha,T} \cdot \grad \dot{c}_\alpha + \bfD^\text{eq}_{,T} \cdot \grad \dot{\Phi} \right).
  \end{aligned}
\end{equation}