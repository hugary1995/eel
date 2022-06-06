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

[Kernels]
  [td+]
    type = CoefTimeDerivative
    variable = c+
    Coefficient = 1
  []
  [td-]
    type = CoefTimeDerivative
    variable = c-
    Coefficient = 1
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
  [fick+]
    type = FicksFirstLaw
    chemical_energy_density = psi_c+
    diffusivity = D
    concentration = c+
  []
  [fick-]
    type = FicksFirstLaw
    chemical_energy_density = psi_c-
    diffusivity = D
    concentration = c-
  []
  [mass_flux+]
    type = MassFlux
    mass_flux = J+
    concentration = c+
    energy_densities = 'psi_c+ psi_c-'
  []
  [mass_flux-]
    type = MassFlux
    mass_flux = J-
    concentration = c-
    energy_densities = 'psi_c+ psi_c-'
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
