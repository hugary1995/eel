# units are in meter kelvin second (m,kg,s)

# frequency
f = 100
omega = '${fparse 2*pi*f}'
tramp = 60

tcharge = 28800 # 8hr*3600
end_time = '${tcharge}'

dtmax = 60
dt = 1

T_melting = '${fparse 350+273.15}'
delta_T_pc = 8 # The temperature range of the melting/solidification process
L = 373.9e3 # Latent heat

# kappa_PCMGF = 18.8 # W/m-K (average of Kxy = 14 W/m-K, Kz = 23.6 W/mK at T=700C) #from Singh et al. Solar energy 159(2018) 270-282 (Prototype 1)
kappa_PCMGF_rr = 14 # W/m-K
kappa_PCMGF_tt = 14 # W/m-K
kappa_PCMGF_zz = 23.6 # W/m-K
rho_PCMGF = 2050 # kg/m^3
cp_PCMGF = 1074 # J/kg-K

kappa_tube_T = '298.15 373.15 473.15 573.15 673.15 773.15 873.15 973.15 1023.15'
kappa_tube = '14.1 15.4 16.8 18.3 19.7 21.2 22.4 23.9 24.6' # W/m-K
rho_tube = 8030 # kg/m^3
cp_tube = 550 # J/kg-K

kappa_container_T = '298.15 373.15 473.15 573.15 673.15 773.15 873.15 973.15 1023.15'
kappa_container = '14.1 15.4 16.8 18.3 19.7 21.2 22.4 23.9 24.6' # W/m-K
rho_container = 8030 # kg/m^3
cp_container = 550 # J/kg-K

kappa_insulation = 0.12 # W/m-K (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
rho_insulation = 2730 # kg/m^3 (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31
cp_insulation = 1130 # J/kg-K (Durablanket S from UNIFRAX) Wen emailed on 2023-03-31

htc_insul = 5
T_inf_insul = 300
htc_tube = 5
T_inf_tube = 300
T0 = 300

# applied current density
V = 15 # Volt
R_coil = 0.23775 # m
n_coil = 9
sigma_coil = 5.8e7 # S/m
i = '${fparse sigma_coil*V/2/pi/R_coil/n_coil}'
r_coil = 0.0127 # m
I = '${fparse i*pi*r_coil^2}'
P = '${fparse V*I}'

# magnetic permeability
mu_air = 1.26e-6
mu_tube = '${fparse 1.004*mu_air}'
mu_PCMGF = '${fparse 1*mu_air}'
mu_container = '${fparse 1.004*mu_air}'
mu_insulation = '${fparse 1*mu_air}'
mu_coil = '${fparse 1*mu_air}'

# electrical conducitivity
sigma_air = 1e-12 # 1e-13~1e-9
sigma_tube_T = '255.2222222 366.3333333 477.4444444 588.5555556 671.8888889 699.6666667 727.4444444 810.7777778 921.8888889 1033 1144.111111 1255.222222'
sigma_tube = '1351351.351 1219512.195 1111111.111 1030927.835 980392.1569 970873.7864 961538.4615 925925.9259 892857.1429 869565.2174 854700.8547 833333.3333' # S/m
sigma_PCMGF = 23810 # S/m (from Bob's measurement in radial direction)
sigma_container_T = '255.2222222 366.3333333 477.4444444 588.5555556 671.8888889 699.6666667 727.4444444 810.7777778 921.8888889 1033 1144.111111 1255.222222'
sigma_container = '1351351.351 1219512.195 1111111.111 1030927.835 980392.1569 970873.7864 961538.4615 925925.9259 892857.1429 869565.2174 854700.8547 833333.3333' # S/m
sigma_insulation = 1e3 # S/m

# applied current density
ix = ${i}
iy = 0

[GlobalParams]
  energy_densities = 'H'
[]

[Mesh]
  [fmg0]
    type = FileMeshGenerator
    file = 'gold/model_v002.exo'
  []
  [fmg]
    type = MeshRepairGenerator
    input = fmg0
    fix_elements_orientation = true
  []
  [scale]
    type = TransformGenerator
    input = fmg
    transform = SCALE
    vector_value = '1e-3 1e-3 1e-3'
  []
  coord_type = RZ
[]

[Functions]
  [ix]
    type = ParsedFunction
    expression = 'if(t<${tramp}, ${ix}/${tramp}*t, ${ix})'
  []
  [iy]
    type = ParsedFunction
    expression = 'if(t<${tramp}, ${iy}/${tramp}*t, ${iy})'
  []
[]

[Variables]
  [T]
    initial_condition = ${T0}
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
  [Are_x]
  []
  [Aim_x]
  []
  [Are_y]
  []
  [Aim_y]
  []
[]

[AuxVariables]
  [T_old]
    block = 'tube PCMGF container_pipe container_plate insulation'
    [AuxKernel]
      type = ParsedAux
      expression = 'T'
      coupled_variables = 'T'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
  []
  [phase]
    block = 'PCMGF'
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
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
  [energy_balance_2]
    type = RankOneDivergence
    variable = T
    vector = h
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
  [heat_source]
    type = MaterialSource
    variable = T
    prop = q
    coefficient = -1
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
[]

[Kernels]
  # Real part
  [real_Hdiv_x]
    type = RankTwoDivergence
    variable = Are_x
    tensor = Hre
    component = 0
    factor = -1
  []
  [real_Hdiv_y]
    type = RankTwoDivergence
    variable = Are_y
    tensor = Hre
    component = 1
    factor = -1
  []
  [real_induction_x]
    type = MaterialReaction
    variable = Are_x
    coupled_variable = Aim_x
    prop = ind_coef
    coefficient = -1
  []
  [real_induction_y]
    type = MaterialReaction
    variable = Are_y
    coupled_variable = Aim_y
    prop = ind_coef
    coefficient = -1
  []
  [applied_current_x]
    type = MaterialSource
    variable = Are_x
    prop = ix
    coefficient = 1
    block = 'coil'
  []
  [applied_current_y]
    type = MaterialSource
    variable = Are_y
    prop = iy
    coefficient = 1
    block = 'coil'
  []

  # Imaginary part
  [imag_Hdiv_x]
    type = RankTwoDivergence
    variable = Aim_x
    tensor = Him
    component = 0
    factor = -1
  []
  [imag_Hdiv_y]
    type = RankTwoDivergence
    variable = Aim_y
    tensor = Him
    component = 1
    factor = -1
  []
  [imag_induction_x]
    type = MaterialReaction
    variable = Aim_x
    coupled_variable = Are_x
    prop = ind_coef
    coefficient = 1
  []
  [imag_induction_y]
    type = MaterialReaction
    variable = Aim_y
    coupled_variable = Are_y
    prop = ind_coef
    coefficient = 1
  []
[]

[BCs]
  [hconv_insul]
    type = ADMatNeumannBC
    variable = T
    boundary = 'insul_top insul_od insul_bot'
    value = -1
    boundary_material = qconv_insul
  []
  [hconv_tube]
    type = ADMatNeumannBC
    variable = T
    boundary = 'pipe_id'
    value = -1
    boundary_material = qconv_tube
  []
[]

[Materials]
  [tube]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp'
    prop_values = '${rho_tube} ${cp_tube}'
    block = 'tube'
  []
  [tube_kappa]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'kappa_iso'
    variable = 'T'
    x = ${kappa_tube_T}
    y = ${kappa_tube}
    block = 'tube'
  []
  [PCMGF]
    type = ADGenericConstantMaterial
    prop_names = 'rho'
    prop_values = '${rho_PCMGF}'
    block = 'PCMGF'
  []
  [PCMGF_kappa]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'kappa'
    tensor_values = '${kappa_PCMGF_rr} ${kappa_PCMGF_tt} ${kappa_PCMGF_zz}'
    block = 'PCMGF'
  []
  [container]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp'
    prop_values = '${rho_container} ${cp_container}'
    block = 'container_pipe container_plate'
  []
  [container_kappa]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'kappa_iso'
    variable = 'T'
    x = ${kappa_container_T}
    y = ${kappa_container}
    block = 'container_pipe container_plate'
  []
  [insulation]
    type = ADGenericConstantMaterial
    prop_names = 'rho cp'
    prop_values = '${rho_insulation} ${cp_insulation}'
    block = 'insulation'
  []
  [insulation_kappa]
    type = ADGenericConstantMaterial
    prop_names = 'kappa_iso'
    prop_values = '${kappa_insulation}'
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
    block = 'PCMGF'
  []
  [specific_heat_PCMGF]
    type = ADParsedMaterial
    property_name = cp
    expression = '${cp_PCMGF} + ${L} * D'
    material_property_names = 'D'
    block = 'PCMGF'
  []
  [heat_conduction]
    type = FourierPotential
    thermal_energy_density = H
    thermal_conductivity = kappa_iso
    temperature = T
    block = 'tube container_pipe container_plate insulation'
  []
  [heat_conduction_PCMGF]
    type = AnisotropicFourierPotential
    thermal_energy_density = H
    thermal_conductivity = kappa
    temperature = T
    block = 'PCMGF'
  []
  [heat_flux]
    type = HeatFlux
    heat_flux = h
    temperature = T
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
  [qconv_insul]
    type = ADParsedMaterial
    property_name = qconv_insul
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_insul} ${T_inf_insul}'
    boundary = 'insul_top insul_od insul_bot'
  []
  [qconv_tube]
    type = ADParsedMaterial
    property_name = qconv_tube
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc_tube} ${T_inf_tube}'
    boundary = 'pipe_id'
  []
  [delta_enthalpy]
    type = ADParsedMaterial
    property_name = 'dh'
    expression = 'rho*cp*(T-T_old)/2'
    material_property_names = 'rho cp'
    coupled_variables = 'T T_old'
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
[]

[Materials]
  [tube_mu]
    type = ADGenericConstantMaterial
    prop_names = 'mu'
    prop_values = '${mu_tube}'
    block = 'tube'
  []
  [tube_sigma]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'sigma'
    variable = 'T'
    x = ${sigma_tube_T}
    y = ${sigma_tube}
    block = 'tube'
  []
  [PCMGF_mu_sigma]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_PCMGF} ${sigma_PCMGF}'
    block = 'PCMGF'
  []
  [container_mu]
    type = ADGenericConstantMaterial
    prop_names = 'mu'
    prop_values = '${mu_container}'
    block = 'container_pipe container_plate'
  []
  [container_sigma]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'sigma'
    variable = 'T'
    x = ${sigma_container_T}
    y = ${sigma_container}
    block = 'container_pipe container_plate'
  []
  [insulation_mu_sigma]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_insulation} ${sigma_insulation}'
    block = 'insulation'
  []
  [air_mu_sigma]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_air} ${sigma_air}'
    block = 'air'
  []
  [coil_mu_sigma]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_coil} ${sigma_coil}'
    block = 'coil'
  []
  [magnetizing_field_real]
    type = MagnetizingTensor
    magnetizing_tensor = Hre
    magnetic_vector_potential = 'Are_x Are_y'
    magnetic_permeability = mu
  []
  [magnetizing_field_imag]
    type = MagnetizingTensor
    magnetizing_tensor = Him
    magnetic_vector_potential = 'Aim_x Aim_y'
    magnetic_permeability = mu
  []
  [induction_coef]
    type = ADParsedMaterial
    property_name = ind_coef
    expression = 'omega * sigma'
    material_property_names = 'omega sigma'
    block = 'tube PCMGF container_pipe container_plate insulation air'
  []
  [induction_coef_coil]
    type = ADGenericConstantMaterial
    prop_names = 'ind_coef'
    prop_values = '0'
    block = 'coil'
  []
  [frequency]
    type = ADGenericFunctionMaterial
    prop_names = 'omega'
    prop_values = '${omega}'
  []
  [i]
    type = ADGenericFunctionMaterial
    prop_names = 'ix iy'
    prop_values = 'ix iy'
    block = 'coil'
  []
  [current]
    type = EddyCurrent
    current_density = ie
    frequency = omega
    electrical_conductivity = sigma
    magnetic_vector_potential_real = 'Are_x Are_y'
    magnetic_vector_potential_imaginary = 'Aim_x Aim_y'
  []
  [heat]
    type = InductionHeating
    heat_source = q
    frequency = omega
    electrical_conductivity = sigma
    magnetic_vector_potential_real = 'Are_x Are_y'
    magnetic_vector_potential_imaginary = 'Aim_x Aim_y'
    block = 'tube PCMGF container_pipe container_plate insulation'
  []
[]

[Postprocessors]
  [PCMGF_volume]
    type = VolumePostprocessor
    block = 'PCMGF'
    execute_on = 'INITIAL'
    outputs = none
  []
  [PCMGF_molten]
    type = ElementIntegralVariablePostprocessor
    variable = phase
    block = 'PCMGF'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [molten_fraction]
    type = ParsedPostprocessor
    pp_names = 'PCMGF_molten PCMGF_volume'
    function = 'PCMGF_molten/PCMGF_volume'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PCMGF_Tmax]
    type = NodalExtremeValue
    variable = T
    block = 'PCMGF'
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # energy in tube
  [dH_tube]
    type = ADElementIntegralMaterialProperty
    mat_prop = dh
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'tube'
    outputs = none
  []
  [H_tube]
    type = CumulativeValuePostprocessor
    postprocessor = 'dH_tube'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # energy in PCMGF
  [dH_PCMGF]
    type = ADElementIntegralMaterialProperty
    mat_prop = dh
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'PCMGF'
    outputs = none
  []
  [H_PCMGF]
    type = CumulativeValuePostprocessor
    postprocessor = 'dH_PCMGF'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # energy in container
  [dH_container]
    type = ADElementIntegralMaterialProperty
    mat_prop = dh
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'container_pipe container_plate'
    outputs = none
  []
  [H_container]
    type = CumulativeValuePostprocessor
    postprocessor = 'dH_container'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # energy in insulation
  [dH_insulation]
    type = ADElementIntegralMaterialProperty
    mat_prop = dh
    execute_on = 'INITIAL TIMESTEP_END'
    block = 'insulation'
    outputs = none
  []
  [H_insulation]
    type = CumulativeValuePostprocessor
    postprocessor = 'dH_insulation'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [P]
    type = FunctionValuePostprocessor
    function = '${P}'
    execute_on = 'INITIAL'
  []
  [E]
    type = TimeIntegratedPostprocessor
    value = P
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [H]
    type = ParsedPostprocessor
    pp_names = 'H_tube H_PCMGF H_container H_insulation'
    function = 'H_tube+H_PCMGF+H_container+H_insulation'
  []
  [power]
    type = ADElementIntegralMaterialProperty
    mat_prop = q
    block = 'tube PCMGF container_pipe container_plate insulation'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill]
    type = Terminator
    expression = 'molten_fraction>0.95'
    message = '95% of PCM has molten.'
    execute_on = 'TIMESTEP_END'
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
  dtmax = ${dtmax}
  dtmin = 1e-11
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    cutback_factor = 0.2
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    optimal_iterations = 8
    iteration_window = 3
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
  l_max_its = 150
[]

[Outputs]
  file_base = 'charging_f_${f}/out'
  exodus = true
  csv = true
  print_linear_residuals = false
[]
