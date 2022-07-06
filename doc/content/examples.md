# Examples

## Simple mixing of two species
style=text-decoration:underline;
id=mixing

+Physics+: Chemical reactions

This example problem demontrates the mixing of two species. The balance of mass states

\begin{equation}
  \begin{aligned}
    -\divergence \bfJ_+ + \mu_+ &= 0 \\
    -\divergence \bfJ_- + \mu_- &= 0
  \end{aligned}
\end{equation}

where the mass flux follows the Fick's first law defined using [`FicksFirstLaw`](FicksFirstLaw.md), and the mass source results from dissipation of viscous mass transport defined using [`ViscousMassTransport`](ViscousMassTransport.md).

[The complete input file](tests/chemical/mixing.i)

The animation of the result:

!media animations/mixing.mp4
       style=width:70%;margin:auto;

## Electric potential of a uniformly charged sphere
style=text-decoration:underline;

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

[The complete input file](tests/electrical/uniform_sphere_charge.i)

## Redox at the electrode-electrolyte interface
style=text-decoration:underline;

+Physics+: electrostatics

In this test, an electrode-electrolyte system is considered. The electrode $x \in [0, 0.5]$ and the electrolyte $x \in [0.5, 1]$ share an interface at $x = 0.5$. The Butler-Volmer condition is enforced at the interface to model redox using [`Redox`](Redox.md). The numerical solution of the electric potential matches the analytical solution.

[The complete input file](tests/electrical/redox.i)

## Swelling induced deformation
style=text-decoration:underline;
id=swelling

+Physics+: mechanics

In this example, there is no external forces applied on the body. The balance of linear momentum states

\begin{equation}
  \divergence \bfP = \bs{0},
\end{equation}

where the first Piola Kirchhoff stress is defined by a Neo-Hookean type elastic energy [`NeoHookeanElasticEnergyDensity`](NeoHookeanElasticEnergyDensity.md). The deformation comes from swelling induced by concentration changes, defined by [`SwellingDeformationGradient`](SwellingDeformationGradient.md). The deformation is not uniform since the molar volumes of the species are assumed to be different.

[The complete input file](tests/mechanical/swelling.i)

The animation of the result:

!media animations/swelling.mp4
       style=width:70%;margin:auto;

## Stress-assisted diffusion
style=text-decoration:underline;

+Physics+: chemical reactions, mechanics

In this example, the initially uniformly distributed concentration is "pumped" from left to right via stress assisted diffusion. It is worth noting that the variational framework allows us to define the system assuming an additive decomposition of chemical energy and mechanical energy, i.e.

\begin{equation}
  \psi = \psi^c + \psi^m,
\end{equation}

and all the coupled consitutive relations follow from the variation. In terms of input file, since the implementation in Stingray strictly follows the variational framework, the model definition of this coupled system is a straight-forward merging of models defining separate physics, e.g. [#mixing] and [#swelling].

[The complete input file](tests/chemical-mechanical/stress_assisted_diffusion.i)

The animation of the result:

!media animations/stress_assisted_diffusion.mp4
       style=width:90%;margin:auto;

## Charging and Joule heating
style=text-decoration:underline;

+Physics+: chemical reactions, electrostatics, thermal effects

In this example problem, galvanostatic charging is modeled with a constant electric potential on both ends of the body. The mass transport of the charged species is defined by [`Charging`](Charging.md). Heat generated due to the prescence of the current is defined by [`JouleHeating`](JouleHeating.md).

[The complete input file, part I](tests/chemical-electrical-thermal/base.i)

[The complete input file, part II](tests/chemical-electrical-thermal/charge_galvanostatic.i)