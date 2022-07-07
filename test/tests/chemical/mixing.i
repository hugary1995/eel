# This test demonstrates the simple mixing of two species

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 2
    nz = 2
  []
[]

[Variables]
  [c+]
    [InitialCondition]
      type = FunctionIC
      function = 'x'
    []
  []
  [c-]
    [InitialCondition]
      type = FunctionIC
      function = '1-x'
    []
  []
[]

[AuxVariables]
  [T]
    initial_condition = 1
  []
[]

[Kernels]
  [source+]
    type = MaterialSource
    variable = c+
    prop = mu+
  []
  [source-]
    type = MaterialSource
    variable = c-
    prop = mu-
  []
  [diffusion+]
    type = RankOneDivergence
    variable = c+
    vector = J+
  []
  [diffusion-]
    type = RankOneDivergence
    variable = c-
    vector = J-
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
  [viscosity+]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c+*
    concentration = c+
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1
  []
  [viscosity-]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c-*
    concentration = c-
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1
  []
  [fick+]
    type = FicksFirstLaw
    chemical_energy_density = psi_c+
    concentration = c+
    diffusivity = D
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1
  []
  [fick-]
    type = FicksFirstLaw
    chemical_energy_density = psi_c-
    concentration = c-
    diffusivity = D
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1
  []
  [mass_source+]
    type = MassSource
    mass_source = mu+
    concentration = c+
    energy_densities = 'psi_c+ psi_c-'
    dissipation_densities = 'psi_c+* psi_c-*'
  []
  [mass_source-]
    type = MassSource
    mass_source = mu-
    concentration = c-
    energy_densities = 'psi_c+ psi_c-'
    dissipation_densities = 'psi_c+* psi_c-*'
  []
  [mass_flux+]
    type = MassFlux
    mass_flux = J+
    concentration = c+
    energy_densities = 'psi_c+ psi_c-'
    dissipation_densities = 'psi_c+* psi_c-*'
  []
  [mass_flux-]
    type = MassFlux
    mass_flux = J-
    concentration = c-
    energy_densities = 'psi_c+ psi_c-'
    dissipation_densities = 'psi_c+* psi_c-*'
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
