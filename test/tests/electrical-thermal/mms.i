n = 32

[GlobalParams]
  energy_densities = 'E H'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 0
    xmax = 1
    nx = ${n}
  []
[]

[Variables]
  [Phi]
  []
  [T]
  []
[]

[Functions]
  [Phi]
    type = ParsedFunction
    value = '3.565*exp(x)-4.71*x^2+7.1*x-3.4'
  []
  [sigma]
    type = ParsedFunction
    value = '1+x'
  []
  [q]
    type = ParsedFunction
    value = '2.32+exp(x)*(-7.13-3.565*x)+18.84*x'
  []
  [kappa]
    type = ParsedFunction
    value = '2.6*x+3'
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  [charge]
    type = BodyForce
    variable = Phi
    function = q
  []
  [energy_balance_1]
    type = RankOneDivergence
    variable = T
    vector = h
  []
  [energy_balance_2]
    type = MaterialSource
    variable = T
    prop = r
  []
[]

[BCs]
  [fix]
    type = FunctionDirichletBC
    variable = Phi
    boundary = 'left right'
    function = Phi
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = right
    value = 1
    boundary_material = qconv
  []
[]

[Materials]
  [electric_constants]
    type = ADGenericFunctionRankTwoTensor
    tensor_name = 'sigma'
    tensor_functions = 'sigma sigma sigma'
  []
  [charge_trasport]
    type = BulkChargeTransport
    electrical_energy_density = E
    electric_potential = Phi
    electric_conductivity = sigma
    temperature = T
  []
  [current]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
  []
  [thermal_constants]
    type = ADGenericFunctionRankTwoTensor
    tensor_name = 'kappa'
    tensor_functions = 'kappa kappa kappa'
  []
  [heat_conduction]
    type = HeatConduction
    thermal_energy_density = H
    thermal_conductivity = kappa
    temperature = T
  []
  [heat_flux]
    type = HeatFlux
    heat_flux = h
    temperature = T
  []
  [heat_source]
    type = HeatSource
    heat_source = r
    temperature = T
  []
  [qconv]
    type = ADParsedMaterial
    f_name = qconv
    function = 'htc*(T-T_inf)'
    args = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '135 300'
    boundary = right
  []
[]

[Postprocessors]
  [error]
    type = ElementL2Error
    variable = Phi
    function = Phi
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  num_steps = 1
[]

[VectorPostprocessors]
  [T]
    type = LineValueSampler
    variable = T
    start_point = '0 0 0'
    end_point = '1 0 0'
    num_points = 20
    sort_by = x
  []
[]

[Outputs]
  [csv]
    type = CSV
    file_base = mms
    execute_vector_postprocessors_on = FINAL
  []
  exodus = true
[]
