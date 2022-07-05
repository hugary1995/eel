# Examples

## Simple mixing of two species

+Physics+: Chemical reactions

This example problem demontrates the mixing of two species. The balance of mass states

\begin{equation}
  \begin{aligned}
    -\divergence \bfJ_+ + \mu_+ &= 0 \\
    -\divergence \bfJ_- + \mu_- &= 0
  \end{aligned}
\end{equation}

where the mass flux follows the Fick's first law defined using [`FicksFirstLaw`](FicksFirstLaw.md), and the mass source results from dissipation of viscous mass transport defined using [`ViscousMassTransport`](ViscousMassTransport.md).

The complete input file for this problem:

!listing tests/chemical/mixing.i
         max-height=150px

The animation of the result:

!media animations/mixing.mp4
       style=width:70%;margin:auto;

## Electric potential of a uniformly charged sphere

+Physics+: electrostatics

This example verifies the analytical solution of the electric potential associated with a uniformly charged sphere. The balance of charge states

\begin{equation}
  \begin{aligned}
    -\divergence \bfD + \rho_q = 0,
  \end{aligned}
\end{equation}

where the electric displacement $\bfD$ is defined by [`Polarization`](Polarization.md), and $\rho_q$ is the prescribed charge density equivalent to a uniformly charged sphere of radius $R$. The numerical solution matches the analytical solution of the electric potential.

\begin{equation}
  \begin{aligned}
    \Phi = 
    \begin{cases}
      \dfrac{kQ}{R}, & r > R \\
      \dfrac{kQ}{2R} \left( 3 - \dfrac{r^2}{R^2} \right), & r < R.
    \end{cases}
  \end{aligned}
\end{equation}

The complete input file for this problem:

!listing tests/electrical/uniform_sphere_charge.i
         max-height=150px

## Redox at the electrode-electrolyte interface

+Physics+: electrostatics

In this test, an electrode-electrolyte system is considered. The electrode $x \in [0, 0.5]$ and the electrolyte $x \in [0.5, 1]$ share an interface at $x = 0.5$. The Butler-Volmer condition is enforced at the interface to model redox using [`Redox`](Redox.md). The numerical solution of the electric potential matches the analytical solution.

The complete input file for this problem:

!listing tests/electrical/redox.i
         max-height=150px

## Swelling induced deformation

+Physics+: mechanics

In this example, there is no external forces applied on the body. The deformation comes from swelling induced by concentration changes. The deformation is not uniform since the molar volumes of the species are assumed to be different.

The complete input file for this problem:

!listing tests/mechanical/swelling.i
         max-height=150px