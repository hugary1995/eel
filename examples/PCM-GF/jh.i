# There are two domains PCM for the phase change material, and G for the graphite.
# The bottom is grounded, the top has a current flux.
# The current is being ramped up from 0 to i over a period of time t0.
# The left and right boundaries have heat convection boundary conditions.
# Top and bottom I'm not sure... the default is zero heat flux.

sigma_PCM = 1
kappa_PCM = 1
rho_PCM = 1
cp_PCM = 1

sigma_G = 1
kappa_G = 1
rho_G = 1
cp_G = 1

htc = 1
T_inf = 300
T0 = 300
t0 = 10
i = 1

[GlobalParams]
  energy_densities = 'E H'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/PCM-GF.msh'
    # file = 'gold/PCM-GF-SiC.msh' # this alternative mesh has one more subdomain "SiC"
  []
[]

[Variables]
  [Phi]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  [energy_balance_1]
    type = EnergyBalanceTimeDerivative
    variable = T
    density = rho
    specific_heat = cp
  []
  [energy_balance_2]
    type = RankOneDivergence
    variable = T
    vector = h
  []
  [energy_balance_3]
    type = MaterialSource
    variable = T
    prop = r
    coefficient = -1
  []
[]

[Functions]
  [ramp]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${i}'
  []
[]

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'bottom'
    value = 0
  []
  [current]
    type = FunctionNeumannBC
    variable = Phi
    boundary = 'top'
    function = ramp
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = 'left right'
    value = -1
    boundary_material = qconv
  []
[]

[Materials]
  [electrical_conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = sigma
    subdomain_to_prop_value = 'PCM ${sigma_PCM} G ${sigma_G}'
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
  [thermal_conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = kappa
    subdomain_to_prop_value = 'PCM ${kappa_PCM} G ${kappa_G}'
  []
  [density]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = rho
    subdomain_to_prop_value = 'PCM ${rho_PCM} G ${rho_G}'
  []
  [specific_heat]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = cp
    subdomain_to_prop_value = 'PCM ${cp_PCM} G ${cp_G}'
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
    property_name = qconv
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc} ${T_inf}'
    boundary = 'left right'
  []
  [entropy]
    type = ADParsedMaterial
    property_name = entropy
    expression = 'rho*cp*(T-${T0})'
    material_property_names = 'rho cp'
    coupled_variables = 'T'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 7
    iteration_window = 2
    linear_iteration_ratio = 100000
  []

  steady_state_detection = true
[]

[Postprocessors]
  [volume_PCM]
    type = VolumePostprocessor
    block = PCM
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [volume_G]
    type = VolumePostprocessor
    block = G
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [porosity]
    type = ParsedPostprocessor
    function = 'volume_PCM/(volume_G+volume_PCM)'
    pp_names = 'volume_G volume_PCM'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [energy_absorbed_by_PCM]
    type = ADElementIntegralMaterialProperty
    mat_prop = entropy
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
[]
