R = 8.3145
T = 300
D = 1

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
    type = TimeDerivative
    variable = c
  []
  [mass_balance]
    type = RankOneDivergence
    variable = c
    vector = j
  []
[]

[Materials]
  [mobility]
    type = ADParsedMaterial
    f_name = M
    args = 'c T'
    function = '${D}*c/${R}/T'
  []
  [diffusion]
    type = MassDiffusion
    mass_flux = j
    mobility = M
    ideal_gas_constant = ${R}
    temperature = T
    concentration = c
    reference_concentration = c
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
