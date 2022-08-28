R = 8.3145
T = 300
D = 1

[GlobalParams]
  energy_densities = 'G'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 10
    nx = 10
  []
[]

[Variables]
  [c]
    [InitialCondition]
      type = FunctionIC
      function = '-(x-5)^2/25+1'
    []
  []
[]

[AuxVariables]
  [T]
    initial_condition = ${T}
  []
[]

[Kernels]
  [mass_balance_time]
    type = MassBalanceTimeDerivative
    variable = c
    ideal_gas_constant = ${R}
    temperature = T
  []
  [mass_balance_1]
    type = RankOneDivergence
    variable = c
    vector = j
  []
  [mass_balance_2]
    type = MaterialSource
    variable = c
    prop = m
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
  []
  [diffusion]
    type = MassDiffusion
    chemical_energy_density = G
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    diffusivity = D
  []
  [mass_source]
    type = MassSource
    mass_source = m
    concentration = c
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    concentration = c
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20

  num_steps = 10
[]

[Outputs]
  exodus = true
[]
