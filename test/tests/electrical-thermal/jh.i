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
    expression = '3.565*exp(x)-4.71*x^2+7.1*x-3.4'
  []
  [sigma]
    type = ParsedFunction
    expression = '1+x'
  []
  [q]
    type = ParsedFunction
    expression = '2.32+exp(x)*(-7.13-3.565*x)+18.84*x'
  []
  [kappa]
    type = ParsedFunction
    expression = '-2.6*x+3'
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
    coefficient = -1
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
    value = -1
    boundary_material = qconv
  []
[]

[Materials]
  [electric_constants]
    type = ADGenericFunctionMaterial
    prop_names = 'sigma'
    prop_values = 'sigma'
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
    type = ADGenericFunctionMaterial
    prop_names = 'kappa'
    prop_values = 'kappa'
  []
  [heat_conduction]
    type = FourierPotential
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
    type = VariationalHeatSource
    heat_source = r
    temperature = T
  []
  [qconv]
    type = ADParsedMaterial
    property_name = qconv
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '1.35 300'
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

[Outputs]
  exodus = true
[]
