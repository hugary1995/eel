# units are in meter kelvin second (m,kg,s)

tcharge = 8000 # 3hr*3600
end_time = '${tcharge}'

dtmax = 600
dt = 1

T_melting = '${fparse 350+273.15}'
delta_T_pc = 8 # The temperature range of the melting/solidification process
L = 373.9e3 # Latent heat

kappa_PCM = 18.8 # W/m-K
rho_PCM = 2050 # kg/m^3
cp_PCM = 1074 # J/kg-K

kappa_pipe = 23.9 # W/m-K
rho_pipe = 8359.33 # kg/m^3
cp_pipe = 419 # J/kg-K

kappa_container = 23.9 # W/m-K
rho_container = 8359.33 # kg/m^3
cp_container = 419 # J/kg-K

kappa_insulation = 0.12 # W/m-K (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
rho_insulation = 2730 # kg/m^3 (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
cp_insulation = 1130 # J/kg-K (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31

htc_insul = 5
T_inf_insul = 300
htc_pipe = 0.01
T_inf_pipe = 300
T0 = 300

[GlobalParams]
  energy_densities = 'H'
[]

[Problem]
  kernel_coverage_check = false
  material_coverage_check = false
[]

[MultiApps]
  [induction]
    type = TransientMultiApp
    input_files = 'induction.i'
  []
[]

[Transfers]
  [to_T]
    type = MultiAppCopyTransfer
    to_multi_app = 'induction'
    source_variable = 'T'
    variable = 'T'
  []
  [from_q]
    type = MultiAppCopyTransfer
    from_multi_app = 'induction'
    source_variable = 'q'
    variable = 'q'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/domain.msh'
  []
  coord_type = RZ
[]

[Variables]
  [T]
    block = 'pipe PCM container insulation'
    initial_condition = ${T0}
  []
[]

[AuxVariables]
  [q]
    order = CONSTANT
    family = MONOMIAL
    block = 'pipe PCM container insulation'
  []
  [T_old]
    block = 'pipe PCM container insulation'
    [AuxKernel]
      type = ParsedAux
      expression = 'T'
      coupled_variables = 'T'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
  []
  [phase]
    block = 'PCM'
    [AuxKernel]
      type = ParsedAux
      expression = 'if(T<Tm, 0, if(T<Tm+dT, (T-Tm)/dT, 1))'
      coupled_variables = 'T'
      constant_names = 'Tm dT'
      constant_expressions = '${T_melting} ${delta_T_pc}'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
  []
[]

[Kernels]
  [energy_balance_1]
    type = EnergyBalanceTimeDerivative
    variable = T
    density = rho
    specific_heat = cp
    block = 'pipe PCM container insulation'
  []
  [energy_balance_2]
    type = RankOneDivergence
    variable = T
    vector = h
    block = 'pipe PCM container insulation'
  []
  [heat_source]
    type = CoupledForce
    variable = T
    v = q
    block = 'pipe PCM container insulation'
  []
[]

[BCs]
  [hconv_insul]
    type = ADMatNeumannBC
    variable = T
    boundary = 'insulation_surface'
    value = -1
    boundary_material = qconv_insul
  []
  [hconv_pipe]
    type = ADMatNeumannBC
    variable = T
    boundary = 'pipe_surface'
    value = -1
    boundary_material = qconv_pipe
  []
[]

[Materials]
  [pipe]
    type = ADGenericConstantMaterial
    prop_names = 'kappa rho cp'
    prop_values = '${kappa_pipe} ${rho_pipe} ${cp_pipe}'
    block = 'pipe'
  []
  [PCM]
    type = ADGenericConstantMaterial
    prop_names = 'kappa rho'
    prop_values = '${kappa_PCM} ${rho_PCM}'
    block = 'PCM'
  []
  [container]
    type = ADGenericConstantMaterial
    prop_names = 'kappa rho cp'
    prop_values = '${kappa_container} ${rho_container} ${cp_container}'
    block = 'container'
  []
  [insulation]
    type = ADGenericConstantMaterial
    prop_names = 'kappa rho cp'
    prop_values = '${kappa_insulation} ${rho_insulation} ${cp_insulation}'
    block = 'insulation'
  []
  # For melting and solidification
  [gaussian_function]
    type = ADParsedMaterial
    property_name = D
    expression = 'exp(-T*(T-Tm)^2/dT^2)/sqrt(3.1415926*dT^2)'
    coupled_variables = 'T'
    constant_names = 'Tm dT'
    constant_expressions = '${T_melting} ${delta_T_pc}'
    block = 'PCM'
  []
  [specific_heat_PCM]
    type = ADParsedMaterial
    property_name = cp
    expression = '${cp_PCM} + ${L} * D'
    material_property_names = 'D'
    block = 'PCM'
  []
  [heat_conduction]
    type = FourierPotential
    thermal_energy_density = H
    thermal_conductivity = kappa
    temperature = T
    block = 'pipe PCM container insulation'
  []
  [heat_flux]
    type = HeatFlux
    heat_flux = h
    temperature = T
    block = 'pipe PCM container insulation'
  []
  [qconv_insul]
    type = ADParsedMaterial
    property_name = qconv_insul
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_insul} ${T_inf_insul}'
    boundary = 'insulation_surface'
  []
  [qconv_pipe]
    type = ADParsedMaterial
    property_name = qconv_pipe
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_pipe} ${T_inf_pipe}'
    boundary = 'pipe_surface'
  []
[]

[Postprocessors]
  [PCM_volume]
    type = VolumePostprocessor
    block = 'PCM'
    execute_on = 'INITIAL'
    outputs = none
  []
  [PCM_molten]
    type = ElementIntegralVariablePostprocessor
    variable = phase
    block = 'PCM'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [molten_fraction]
    type = ParsedPostprocessor
    pp_names = 'PCM_molten PCM_volume'
    function = 'PCM_molten/PCM_volume'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PCM_Tmax]
    type = NodalExtremeValue
    variable = T
    block = 'PCM'
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  end_time = ${end_time}
  dtmax = ${dtmax}
  dtmin = 0.01
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    cutback_factor = 0.2
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    optimal_iterations = 7
    iteration_window = 2
    linear_iteration_ratio = 100000
  []
  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
  []

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_max_its = 12
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
