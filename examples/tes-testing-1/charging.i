# units are in meter kelvin second (m,kg,s)

kappa_medium = 18.8 # 18.8 # W/m-K
kappa_steel_T = '298.15 373.15 473.15 573.15 673.15 773.15 873.15 973.15 1023.15'
kappa_steel = '14.1 15.4 16.8 18.3 19.7 21.2 22.4 23.9 24.6' # W/m-K
kappa_insul = 0.4 # W/m-K
kappa_fbrick = 1.25 # W/m-K
kappa_air = 0.026 # W/m-K

rho_foam = 96 # kg/m^3
rho_medium = '${fparse rho_foam*0.2+2050*0.8*0.7}' # kg/m^3, 80% porosity, 70% infiltration rate
rho_steel = 8030 # kg/m^3
rho_insul = 96 # kg/m^3
rho_fbrick = 2000 # kg/m^3
rho_air = 1.225 # kg/m^3

cp_medium = 1074 # J/kg-K, 80% porosity, 70% infiltration rate
cp_steel = 550 # J/kg-K
cp_insul = 1130 # J/kg-K
cp_fbrick = 1000 # J/kg-K
cp_air = 1005 # J/kg-K

T_m = '${fparse 714+273.15}' # K, Melting point
dT_pc = 8
L = 3.739e5 # J/kg, Latent heat

htc = 10 # W/m2-K
T_inf = 300
T0 = 300

kB = 5.67e-8
F = 0.2

end_time = '${fparse 6*3600}' # 6 hrs
dt = 1
dtmax = 200

[GlobalParams]
  energy_densities = 'H'
[]

[MultiApps]
  [induction]
    type = TransientMultiApp
    input_files = 'induction.i'
  []
[]

[Transfers]
  [to_T]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = 'induction'
    source_variable = 'T'
    variable = 'T'
    error_on_miss = false
    extrapolation_constant = ${T0}
  []
  [to_T_ext]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = 'induction'
    source_variable = 'T_ext'
    variable = 'T'
    error_on_miss = false
    extrapolation_constant = ${T0}
  []
  [from_q]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = 'induction'
    source_variable = 'q'
    variable = 'q'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/T.msh'
  []
  [scale]
    type = TransformGenerator
    input = fmg
    transform = SCALE
    vector_value = '0.0254 0.0254 0.0254'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = scale
    block_pairs = 'container insulation; container fbrick; insulation fbrick; pipe insulation; pipe fbrick'
    split_interface = true
    add_interface_on_two_sides = true
  []
  coord_type = RZ
[]

[Variables]
  [T]
    initial_condition = ${T0}
    block = 'pipe medium air container'
  []
  [T_ext]
    initial_condition = ${T0}
    block = 'insulation fbrick'
  []
[]

[AuxVariables]
  [q]
    order = CONSTANT
    family = MONOMIAL
    block = 'pipe medium air container'
  []
  [phase]
    order = CONSTANT
    family = MONOMIAL
    block = 'medium'
    [AuxKernel]
      type = ADMaterialRealAux
      property = phi
      block = 'medium'
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [T_all]
    initial_condition = ${T0}
  []
[]

[AuxKernels]
  [T_all_1]
    type = ParsedAux
    variable = 'T_all'
    expression = 'T'
    coupled_variables = 'T'
    block = 'pipe medium air container'
    execute_on = 'TIMESTEP_END'
  []
  [T_all_2]
    type = ParsedAux
    variable = 'T_all'
    expression = 'T_ext'
    coupled_variables = 'T_ext'
    block = 'insulation fbrick'
    execute_on = 'TIMESTEP_END'
  []
[]

[Kernels]
  [energy_balance_local]
    type = EnergyBalanceTimeDerivative
    variable = T
    density = rho
    specific_heat = cp
    block = 'pipe medium air container'
  []
  [energy_balance_local_latent]
    type = EnergyBalanceTimeDerivative
    variable = T
    density = rho
    specific_heat = cpL
    block = 'medium'
  []
  [energy_balance]
    type = RankOneDivergence
    variable = T
    vector = h
    block = 'pipe medium air container'
  []
  [heat_source]
    type = CoupledForce
    variable = T
    v = q
    block = 'pipe medium air container'
  []
  # ext
  [energy_balance_local_ext]
    type = EnergyBalanceTimeDerivative
    variable = T_ext
    density = rho
    specific_heat = cp
    block = 'insulation fbrick'
  []
  [energy_balance_ext]
    type = RankOneDivergence
    variable = T_ext
    vector = h
    block = 'insulation fbrick'
  []
[]

[BCs]
  [convection]
    type = ADMatNeumannBC
    variable = T_ext
    boundary = 'insulation_outer'
    value = -1
    boundary_material = qconv
  []
  [radiation]
    type = ADMatNeumannBC
    variable = T_ext
    boundary = 'insulation_outer'
    value = -1
    boundary_material = qrad
  []
[]

[InterfaceKernels]
  [gap_insul]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T_ext
    penalty = '4'
    boundary = 'container_insulation pipe_insulation'
  []
  [gap]
    type = InterfaceContinuity
    variable = T_ext
    neighbor_var = T_ext
    penalty = '4'
    boundary = 'insulation_fbrick'
  []
  [gap_fbrick]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T_ext
    penalty = '6.5'
    boundary = 'container_fbrick pipe_fbrick'
  []
[]

[Materials]
  [steel]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp'
    prop_values = '${rho_steel} ${cp_steel}'
    block = 'container pipe'
  []
  [steel_kappa]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'kappa'
    variable = 'T'
    x = ${kappa_steel_T}
    y = ${kappa_steel}
    block = 'container pipe'
  []
  [medium]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp kappa0'
    prop_values = '${rho_medium} ${cp_medium} ${kappa_medium}'
    block = 'medium'
  []
  [insulation]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp kappa'
    prop_values = '${rho_insul} ${cp_insul} ${kappa_insul}'
    block = 'insulation'
  []
  [fbrick]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp kappa'
    prop_values = '${rho_fbrick} ${cp_fbrick} ${kappa_fbrick}'
    block = 'fbrick'
  []
  [air]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp kappa'
    prop_values = '${rho_air} ${cp_air} ${kappa_air}'
    block = 'air'
  []
  [heat_conduction]
    type = FourierPotential
    thermal_energy_density = H
    thermal_conductivity = kappa
    temperature = T
    block = 'pipe medium air container'
  []
  [heat_conduction_ext]
    type = FourierPotential
    thermal_energy_density = H
    thermal_conductivity = kappa
    temperature = T_ext
    block = 'insulation fbrick'
  []
  [heat_flux]
    type = HeatFlux
    heat_flux = h
    temperature = T
    block = 'pipe medium air container'
  []
  [heat_flux_ext]
    type = HeatFlux
    heat_flux = h
    temperature = T_ext
    block = 'insulation fbrick'
  []
  # For melting and solidification
  [phase_change]
    type = TwoPhaseChange
    latent_specific_heat = cpL
    temperature = T
    phase = phi
    starting_temperature = ${T_m}
    ending_temperature = '${fparse T_m+dT_pc}'
    latent_heat = ${L}
    block = 'medium'
  []
  [medium_kappa]
    type = ADParsedMaterial
    property_name = kappa
    expression = '(cp + cpL) / cp * kappa0'
    material_property_names = 'cp cpL kappa0'
    block = 'medium'
  []
  # flux for BCs
  [qconv]
    type = ADParsedMaterial
    property_name = qconv
    expression = 'htc*(T_ext-T_inf)'
    coupled_variables = 'T_ext'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc} ${T_inf}'
    boundary = 'insulation_outer'
  []
  [qrad]
    type = ADParsedMaterial
    property_name = qrad
    expression = 'kB*F*(T_ext^4-T_inf^4)'
    coupled_variables = 'T_ext'
    constant_names = 'T_inf kB F'
    constant_expressions = '${T_inf} ${kB} ${F}'
    boundary = 'insulation_outer'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  automatic_scaling = true
  reuse_preconditioner = true
  reuse_preconditioner_max_linear_its = 25

  end_time = ${end_time}
  dt = ${dt}
  dtmin = 1e-6
  dtmax = ${dtmax}
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

  l_max_its = 100
  l_tol = 1e-06
[]

[Postprocessors]
  [medium_volume]
    type = VolumePostprocessor
    block = 'medium'
    execute_on = 'INITIAL'
    outputs = 'none'
  []
  [medium_molten]
    type = ADElementIntegralMaterialProperty
    mat_prop = phi
    block = 'medium'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'none'
  []
  [medium_molten_fraction]
    type = ParsedPostprocessor
    pp_names = 'medium_molten medium_volume'
    expression = 'medium_molten/medium_volume'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [bottom]
    type = SideAverageValue
    variable = T
    boundary = 'container_fbrick'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [TC4]
    type = PointValue
    variable = T
    point = '${fparse 0.625*0.0254} ${fparse 7*0.0254} 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [TC5]
    type = PointValue
    variable = T
    point = '${fparse 1.125*0.0254} ${fparse 5.5*0.0254} 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [TC6]
    type = PointValue
    variable = T
    point = '${fparse 1.625*0.0254} ${fparse 4*0.0254} 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill]
    type = Terminator
    expression = 'medium_molten_fraction>0.999'
    message = '99.9% of PCM has molten.'
    execute_on = 'TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = false
[]
