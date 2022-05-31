# units are in meter kelvin second (m,kg,s)

tramp = 10
tcharge = 8000 # 3hr*3600
tidle = 86400 #24hr*3600
end_time = '${fparse tcharge+tidle}'

dtmax = 600
dt = 1

T_melting = '${fparse 718+273.15}' # Temperature at which the melting begins, Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
delta_T_pc = 8 # The temperature range of the melting/solidification process
L = 373.9e3 # Latent heat, from Singh et al. (2015)

sigma_foam_PCM = 5 # (from Wen's measurement of Gfoam+PCM in radial direction) (from Cfoam 70% dense foam = 28571.43) S/m (1/electrical resistivity (0.000035 ohm-m))
kappa_foam_PCM = 10 #18.8 # (average of Kxy = 14 W/m-K, Kz = 23.6 W/mK at T=700C) #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
rho_foam_PCM = 2050 # kg/m^3 #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
cp_foam_PCM = 1074 # J/kg-K #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)

sigma_htf_pipe = 750750.75 # S/m (resistivity 1.332e-6 ohm-m at T = 700C) #Special metal data sheet
kappa_htf_pipe = 23.9 # W/m-K (at 700C) #Special metal datasheet
rho_htf_pipe = 8359.33 #kg/m^3
cp_htf_pipe = 419 # J/kg-K

sigma_insul_ht = 1e-9
kappa_insul_ht = 0.12 # W/m-K(Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
rho_insul_ht = 2730 # kg/m^3(Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
cp_insul_ht = 1130 # J/kg-K(Durablanket S from UNIFRAX) Wen emailed on 2023-03-31

sigma_air = 1e-12
kappa_air = 0.03 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf
rho_air = 1.29 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf
cp_air = 1000 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf

htc_insul = 5
T_inf_insul = 300
htc_pipe = 0.01
T_inf_pipe = 300
T0 = 300
# i = 1 # This is the maximum current in constant-current charging
V = 21 # This is the maximum voltage in constant-voltage charging

[GlobalParams]
  energy_densities = 'E H'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/geo.e'
  []
  coord_type = RZ
  uniform_refine = 1
[]

[Variables]
  [Phi]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[AuxVariables]
  [T_old]
    [AuxKernel]
      type = ParsedAux
      expression = 'T'
      coupled_variables = 'T'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
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
  # [ramp_current]
  #   type = PiecewiseLinear
  #   x = '0 ${t0}'
  #   y = '0 ${i}'
  # []
  [ramp_voltage]
    type = PiecewiseLinear
    x = '0 ${tramp} ${tcharge} ${fparse tcharge+tramp} ${fparse tcharge+tidle}'
    y = '0 ${V} ${V} 0 0'
  []
[]

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'foam_id'
    value = 0
  []
  # [current]
  #   type = FunctionNeumannBC
  #   variable = Phi
  #   boundary = 'foam_od'
  #   function = ramp_current
  # []
  [CV]
    type = FunctionDirichletBC
    variable = Phi
    boundary = 'foam_od'
    function = ramp_voltage
  []
  [hconv_insul]
    type = ADMatNeumannBC
    variable = T
    boundary = 'insul_surf'
    value = -1
    boundary_material = qconv_insul
  []
  [hconv_pipe]
    type = ADMatNeumannBC
    variable = T
    boundary = 'pipe_id'
    value = -1
    boundary_material = qconv_pipe
  []
[]

[Materials]
  [electrical_conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = sigma
    subdomain_to_prop_value = 'foam_PCM ${sigma_foam_PCM} htf_pipe ${sigma_htf_pipe} insul_ht ${sigma_insul_ht} air ${sigma_air}'
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
    subdomain_to_prop_value = 'foam_PCM ${kappa_foam_PCM} htf_pipe ${kappa_htf_pipe} insul_ht ${kappa_insul_ht} air ${kappa_air}'
  []
  [density]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = rho
    subdomain_to_prop_value = 'foam_PCM ${rho_foam_PCM} htf_pipe ${rho_htf_pipe} insul_ht ${rho_insul_ht} air ${rho_air}'
  []
  [gaussian_function]
    type = ADParsedMaterial
    property_name = D
    expression = 'exp(-T*(T-Tm)^2/dT^2)/sqrt(3.1415926*dT^2)'
    coupled_variables = 'T'
    constant_names = 'Tm dT'
    constant_expressions = '${T_melting} ${delta_T_pc}'
  []
  [specific_heat_foam_PCM]
    type = ADParsedMaterial
    property_name = cp
    expression = '${cp_foam_PCM} + ${L} * D'
    material_property_names = 'D'
    block = foam_PCM
    outputs = exodus
  []
  [specific_heat]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = cp
    subdomain_to_prop_value = 'htf_pipe ${cp_htf_pipe} insul_ht ${cp_insul_ht} air ${cp_air}'
    block = 'htf_pipe insul_ht air'
    outputs = exodus
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
  [qconv_insul]
    type = ADParsedMaterial
    property_name = qconv_insul
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_insul} ${T_inf_insul}'
    boundary = 'insul_surf'
  []
  [qconv_pipe]
    type = ADParsedMaterial
    property_name = qconv_pipe
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_pipe} ${T_inf_pipe}'
    boundary = 'pipe_id'
  []
  [delta_enthalpy]
    type = ADParsedMaterial
    property_name = delta_enthalpy
    expression = 'rho*cp*(T-T_old)/2'
    material_property_names = 'rho cp'
    coupled_variables = 'T T_old'
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

  # steady_state_detection = true
[]

[Postprocessors]
  [volume_PCM]
    type = VolumePostprocessor
    block = 'foam_PCM'
    execute_on = 'INITIAL TIMESTEP_END'
    # outputs = none
  []
  [delta_energy_absorbed_by_PCM]
    type = ADElementIntegralMaterialProperty
    mat_prop = delta_enthalpy
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'foam_PCM'
    outputs = none
  []
  [delta_energy_absorbed_by_insul_ht]
    type = ADElementIntegralMaterialProperty
    mat_prop = delta_enthalpy
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'insul_ht'
    outputs = none
  []
  [delta_energy_absorbed_by_air]
    type = ADElementIntegralMaterialProperty
    mat_prop = delta_enthalpy
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'air'
    outputs = none
  []
  [delta_energy_absorbed_by_pipe]
    type = ADElementIntegralMaterialProperty
    mat_prop = delta_enthalpy
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'htf_pipe'
    outputs = none
  []
  [energy_absorbed_by_PCM]
    type = CumulativeValuePostprocessor
    postprocessor = delta_energy_absorbed_by_PCM
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [energy_absorbed_by_insul_ht]
    type = CumulativeValuePostprocessor
    postprocessor = delta_energy_absorbed_by_insul_ht
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [energy_absorbed_by_air]
    type = CumulativeValuePostprocessor
    postprocessor = delta_energy_absorbed_by_air
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [energy_absorbed_by_pipe]
    type = CumulativeValuePostprocessor
    postprocessor = delta_energy_absorbed_by_pipe
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [total_energy]
    type = ParsedPostprocessor
    pp_names = 'energy_absorbed_by_PCM energy_absorbed_by_insul_ht energy_absorbed_by_air energy_absorbed_by_pipe'
    function = 'energy_absorbed_by_PCM+energy_absorbed_by_insul_ht+energy_absorbed_by_air+energy_absorbed_by_pipe'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [max_energy]
    type = TimeExtremeValue
    postprocessor = total_energy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [energy_percentage]
    type = ParsedPostprocessor
    pp_names = 'total_energy max_energy'
    function = 'if(total_energy < max_energy, total_energy/max_energy*100, 100)'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [power_input]
    type = ADElementIntegralMaterialProperty
    mat_prop = E
    execute_on = 'INITIAL TIMESTEP_END'
    # outputs = none
  []
  [voltage]
    type = FunctionValuePostprocessor
    function = ramp_voltage
    execute_on = 'INITIAL TIMESTEP_END'
    # outputs = none
  []
  [current_input]
    type = ParsedPostprocessor
    pp_names = 'voltage power_input'
    function = 'power_input / voltage'
    execute_on = 'TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [delta_energy_input]
    type = ParsedPostprocessor
    pp_names = 'dt power_input'
    function = 'power_input * dt'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [energy_input]
    type = CumulativeValuePostprocessor
    postprocessor = delta_energy_input
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PCM_max_temperature]
    type = NodalExtremeValue
    variable = T
    value_type = max
    block = 'foam_PCM'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PCM_min_temperature]
    type = NodalExtremeValue
    variable = T
    value_type = min
    block = 'foam_PCM'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
[]
