## Stingray focuses on modeling battery-related physics, i.e.

- Mass transport of charged species,
- Electrostatics,
- Mechanical deformation,
- Thermal effects,

and =arbitrary ways of coupling= any of the above physics -- thanks to the [variational framework](theory.md) which provides a unified statement and enables a generic implementation interface.

## Stingray is developed within the [MOOSE framework](https://mooseframework.inl.gov), that means Stingray

- uses the FEM discretization,
- is massively parallel (MPI and thread),
- is agnostic to the element implementation,
- supports adaptive h/p refinement,
- supports the [HIT](https://mooseframework.inl.gov/application_usage/input_syntax.html) input file format,
- supports a variety of [mesh formats](https://mooseframework.inl.gov/source/mesh/FileMesh.html)
- and [much, much more](https://mooseframework.inl.gov)

## Installing Stingray is as easy as

1. Install the MOOSE framework following [these instructions](https://mooseframework.inl.gov/getting_started/installation/index.html).
2. Compile Stingray using `make -j N`
3. That's it.

## Useful resources

- The [theory manual](theory.md) summarizes the mathematial background of the problem. 
- The [implementation guide](implementation.md) gives an overview on how the mathematical formulation is translated into Stingray.
- The [list of syntax](stingray.md) provides a complete list of Stingray objects and their usage.
