!config navigation breadcrumbs=False scrollspy=False

# HOME style=visibility:hidden;

!media media/eel.png style=display:block;margin-left:auto;margin-right:auto;width:35%;

# A parallel finite-element code for modeling batteries class=center style=font-weight:200;font-size:200%

## EEL focuses on modeling battery-related physics, i.e.

- Mass transport of charged species,
- Electrostatics/Electrodynamics,
- Mechanical deformation,
- Thermal effects,

and =arbitrary ways of coupling= any of the above physics -- thanks to the variational framework which provides a unified statement and enables a generic implementation interface.

## EEL is developed within the [MOOSE framework](https://mooseframework.inl.gov), that means EEL

- uses the FEM discretization,
- is massively parallel (MPI and thread),
- is agnostic to the element implementation,
- supports adaptive h/p refinement,
- supports the [HIT](https://mooseframework.inl.gov/application_usage/input_syntax.html) input file format,
- supports a variety of [mesh formats](https://mooseframework.inl.gov/source/mesh/FileMesh.html)
- and [much, much more](https://mooseframework.inl.gov)

## Installing EEL is as easy as

1. Install the MOOSE framework following [these instructions](https://mooseframework.inl.gov/getting_started/installation/index.html).
2. Compile EEL using `make -j N`
3. That's it.

## Useful resources

- The [EEL preprint](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4372736) summarizes the mathematial background of the problem.
- The [theory manual](https://www.osti.gov/biblio/1891097) documents some verification tests.
- The [list of syntax](eel.md) provides a complete list of EEL objects and their usage.

