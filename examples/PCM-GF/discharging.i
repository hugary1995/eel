# units are in meter kelvin second (m,kg,s)

end_time = 14400 # 4 hrs

dtmax = 5
dt = 1

sigma_PCM = 5 # (from Wen's measurement of Gfoam+PCM in radial direction) (from Cfoam 70% dense foam = 28571.43) S/m (1/electrical resistivity (0.000035 ohm-m))
kappa_PCM = 10 #18.8 # (average of Kxy = 14 W/m-K, Kz = 23.6 W/mK at T=700C) #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
rho_PCM = 2050 # kg/m^3 #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
cp_PCM = 1074 # J/kg-K #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)

sigma_pipe = 750750.75 # S/m (resistivity 1.332e-6 ohm-m at T = 700C) #Special metal data sheet
kappa_pipe = 23.9 # W/m-K (at 700C) #Special metal datasheet
rho_pipe = 8359.33 #kg/m^3
cp_pipe = 419 # J/kg-K

sigma_gas = 1e-12
kappa_gas = 0.03 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf
rho_gas = 1.29 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf
cp_gas = 1000 #file:///C:/Users/barua/Downloads/PDS-FOAMGLAS%20ONE-US-en.pdf

htc_gas = 0.1
T_inf_gas = 500

htc_insul = 5
T_inf_insul = 300

T_target = 800

[GlobalParams]
  energy_densities = 'E H'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'equilibriate_out.e'
    use_for_exodus_restart = true
  []
  coord_type = RZ
[]

[Variables]
  [Phi]
  []
  [T]
    initial_from_file_var = T
  []
  [v]
    family = LAGRANGE_VEC
    block = gas
  []
  [p]
    block = gas
  []
[]

[ICs]
  [vel]
    type = VectorConstantIC
    variable = v
    x_value = 1e-15
    y_value = 1e-15
    block = gas
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
  [mass]
    type = INSADMass
    variable = p
    block = gas
  []
  [pspg]
    type = INSADMassPSPG
    variable = p
    block = gas
  []
  [momentum_convection]
    type = INSADMomentumAdvection
    variable = v
    block = gas
  []
  [momentum_viscous]
    type = INSADMomentumViscous
    variable = v
    block = gas
  []
  [momentum_pressure]
    type = INSADMomentumPressure
    variable = v
    pressure = p
    integrate_p_by_parts = true
    block = gas
  []
  [momentum_supg]
    type = INSADMomentumSUPG
    variable = v
    velocity = v
    block = gas
  []

  [temperature_advection]
    type = INSADEnergyAdvection
    variable = T
    block = gas
  []
  [temperature_supg]
    type = INSADEnergySUPG
    variable = T
    velocity = v
    block = gas
  []
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

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'PCM_left'
    value = 0
  []
  [voltage]
    type = TargetFeedbackDirichletBC
    variable = Phi
    monitor = T_outlet
    target = ${T_target}
    window = '${fparse 0.02*T_target}'
    idle_value = 0
    maintain_value = 12
    compensate_value = 20
    boundary = 'PCM_right'
  []
  [T_inlet]
    type = DirichletBC
    variable = T
    value = 300
    boundary = 'inlet'
  []
  [velocity_inlet]
    type = VectorFunctionDirichletBC
    variable = v
    function_y = 0.1
    boundary = 'inlet'
  []
  [wall]
    type = VectorFunctionDirichletBC
    variable = v
    boundary = 'wall'
  []
  [hconv_outlet]
    type = ADMatNeumannBC
    variable = T
    boundary = 'outlet'
    value = -1
    boundary_material = qconv_outlet
  []
  [hconv_insul]
    type = ADMatNeumannBC
    variable = T
    boundary = 'insul PCM_right'
    value = -1
    boundary_material = qconv_insul
  []
[]

[Materials]
  [constant]
    type = ADGenericConstantMaterial
    prop_names = 'mu'
    prop_values = '1.8e-5'
  []
  [ins]
    type = INSADStabilized3Eqn
    pressure = p
    velocity = v
    temperature = T
    k_name = kappa
    block = gas
  []
  [electrical_conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = sigma
    subdomain_to_prop_value = 'PCM ${sigma_PCM} pipe ${sigma_pipe} gas ${sigma_gas}'
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
    subdomain_to_prop_value = 'PCM ${kappa_PCM} pipe ${kappa_pipe} gas ${kappa_gas}'
  []
  [density]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = rho
    subdomain_to_prop_value = 'PCM ${rho_PCM} pipe ${rho_pipe} gas ${rho_gas}'
  []
  [specific_heat]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = cp
    subdomain_to_prop_value = 'PCM ${cp_PCM} pipe ${cp_pipe} gas ${cp_gas}'
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
  [qconv_outlet]
    type = ADParsedMaterial
    property_name = qconv_outlet
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_gas} ${T_inf_gas}'
    boundary = 'outlet'
  []
  [qconv_insul]
    type = ADParsedMaterial
    property_name = qconv_insul
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_insul} ${T_inf_insul}'
    boundary = 'insul PCM_right'
  []
  [delta_enthalpy]
    type = ADParsedMaterial
    property_name = delta_enthalpy
    expression = 'rho*cp*(T-T_old)/2'
    material_property_names = 'rho cp'
    coupled_variables = 'T T_old'
  []
[]

[Postprocessors]
  [T_outlet]
    type = SideAverageValue
    variable = T
    boundary = 'outlet'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'
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
  file_base = 'T_target_${T_target}'
  exodus = true
  csv = true
[]
