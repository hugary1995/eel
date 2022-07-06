# This test demonstrates mass transport across an interface following the Henry's law

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 2
    nz = 2
    xmax = 1
    ymax = 0.2
    zmax = 0.2
  []
  [electrolyte]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 1
    bottom_left = '0.5 0 0'
    top_right = '1 0.2 0.2'
  []
  [interface]
    type = BreakMeshByBlockGenerator
    input = electrolyte
    interface_name = interface
  []
[]

[Variables]
  [c]
  []
[]

[InterfaceKernels]
  [interface_mass_transport]
    type = HenrysLaw
    variable = c
    neighbor_var = c
    boundary = interface
    from_subdomain = 0
    to_subdomain = 1
    ratio = 5
    penalty = 10
  []
[]

[Kernels]
  [source]
    type = MaterialSource
    variable = c
    prop = mu
  []
  [diffusion+]
    type = RankOneDivergence
    variable = c
    vector = J
  []
[]

[BCs]
  [left]
    type = FunctionDirichletBC
    variable = c
    boundary = 'left'
    function = 't'
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '1 0 0 0 1 0 0 0 1'
  []
  [properties]
    type = ADGenericConstantMaterial
    prop_names = 'eta'
    prop_values = '1'
  []
  [viscosity]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c*
    viscosity = eta
    concentration = c
  []
  [fick]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    diffusivity = D
    concentration = c
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    concentration = c
    energy_densities = 'psi_c'
    dissipation_densities = 'psi_c*'
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    concentration = c
    energy_densities = 'psi_c'
    dissipation_densities = 'psi_c*'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  dt = 0.01
  end_time = 0.1
[]

[Outputs]
  exodus = true
[]
