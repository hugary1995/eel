I = 3e-3 #mA
width = 0.03 #mm
in = '${fparse -I/width}'
t0 = '${fparse -1e-2/in}'
dt = '${fparse t0/100}'

sigma_a = 1e0 #mS/mm
sigma_e = 1e-1 #mS/mm
sigma_c = 1e-2 #mS/mm

l0 = 0
l1 = 0.04
l2 = 0.07
l3 = 0.12

cmin = 1e-4 #mmol/mm^3
cmax = 1e-3 #mmol/mm^3
D_a = 1e-3 #mm^2/s
D_e = 1e-4 #mm^2/s
D_c = 5e-5 #mm^2/s

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0_a = 1e-1 #mA/mm^2
i0_c = 1e-1 #mA/mm^2

rho = 2.5e-9 #Mg/mm^3
cv = 2.7e8 #mJ/Mg/K
kappa = 2e-4 #mJ/mm/K/s

T_penalty = 2e-1

[GlobalParams]
  energy_densities = 'dot(psi_c) q zeta chi'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = ${l0}
    xmax = ${l3}
    ymin = 0
    ymax = ${width}
    nx = 60
    ny = 15
  []
  [anode]
    type = SubdomainBoundingBoxGenerator
    input = battery
    block_id = 1
    block_name = anode
    bottom_left = '${l0} 0 0'
    top_right = '${l1} ${width} 0'
  []
  [elyte]
    type = SubdomainBoundingBoxGenerator
    input = anode
    block_id = 2
    block_name = elyte
    bottom_left = '${l1} 0 0'
    top_right = '${l2} ${width} 0'
  []
  [cathode]
    type = SubdomainBoundingBoxGenerator
    input = elyte
    block_id = 3
    block_name = cathode
    bottom_left = '${l2} 0 0'
    top_right = '${l3} ${width} 0'
  []
  [anode_elyte]
    type = BreakMeshByBlockGenerator
    input = cathode
    block_pairs = '1 2'
    add_interface_on_two_sides = true
    split_interface = true
  []
  [cathode_elyte]
    type = BreakMeshByBlockGenerator
    input = anode_elyte
    block_pairs = '2 3'
    add_interface_on_two_sides = true
    split_interface = true
  []
[]

[Variables]
  [Phi]
  []
  [c]
  []
  [mu]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[AuxVariables]
  [c_ref]
  []
[]

[ICs]
  [c_min]
    type = ConstantIC
    variable = c
    value = ${cmin}
    block = 'anode'
  []
  [c_mid]
    type = ConstantIC
    variable = c
    value = '${fparse (cmax+cmin)/2}'
    block = 'elyte'
  []
  [c_max]
    type = ConstantIC
    variable = c
    value = ${cmax}
    block = 'cathode'
  []
  [c_ref_min]
    type = ConstantIC
    variable = c_ref
    value = ${cmin}
    block = 'anode'
  []
  [c_ref_mid]
    type = ConstantIC
    variable = c_ref
    value = '${fparse (cmax+cmin)/2}'
    block = 'elyte'
  []
  [c_ref_max]
    type = ConstantIC
    variable = c_ref
    value = ${cmax}
    block = 'cathode'
  []
[]

[Kernels]
  # Charge balance
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  # Mass balance
  [mass_balance_1]
    type = CoupledTimeDerivative
    variable = mu
    v = c
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = mu
    vector = j
  []
  # Chemical potential
  [c]
    type = PrimalDualProjection
    variable = c
    primal_variable = dot(c)
    dual_variable = mu
  []
  # Energy balance
  [energy_balance_1]
    type = EnergyBalanceTimeDerivative
    variable = T
    density = rho
    specific_heat = cv
  []
  [energy_balance_2]
    type = RankOneDivergence
    variable = T
    vector = h
  []
  [heat_source]
    type = MaterialSource
    variable = T
    prop = r
    coefficient = -1
  []
[]

[InterfaceKernels]
  [negative_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    factor = -1
    boundary = 'elyte_anode cathode_elyte'
  []
  [positive_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    boundary = 'anode_elyte elyte_cathode'
  []
  [negative_mass]
    type = MaterialInterfaceNeumannBC
    variable = mu
    neighbor_var = mu
    prop = je
    factor = -1
    boundary = 'elyte_anode cathode_elyte'
  []
  [positive_mass]
    type = MaterialInterfaceNeumannBC
    variable = mu
    neighbor_var = mu
    prop = je
    factor = 1
    boundary = 'anode_elyte elyte_cathode'
  []
  [heat]
    type = MaterialInterfaceNeumannBC
    variable = T
    neighbor_var = T
    prop = he
    factor = 1
    boundary = 'anode_elyte elyte_cathode elyte_anode cathode_elyte'
  []
  [continuity_T]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T
    penalty = ${T_penalty}
    boundary = 'anode_elyte elyte_cathode'
  []
[]

[Functions]
  [in]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${in}'
  []
[]

[BCs]
  [left]
    type = FunctionNeumannBC
    variable = Phi
    boundary = left
    function = in
  []
  [right]
    type = DirichletBC
    variable = Phi
    boundary = right
    value = 0
  []
[]

[Materials]
  # Electrodynamics
  [conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'sigma'
    subdomain_to_prop_value = 'anode ${sigma_a} elyte ${sigma_e} cathode ${sigma_c}'
  []
  [charge_transport]
    type = BulkChargeTransport
    electrical_energy_density = q
    electric_potential = Phi
    electric_conductivity = sigma
    temperature = T
  []
  [current_density]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
  []

  # Chemical reactions
  [diffusivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'D'
    subdomain_to_prop_value = 'anode ${D_a} elyte ${D_e} cathode ${D_c}'
  []
  [mobility]
    type = ADParsedMaterial
    f_name = M
    args = 'c_ref T'
    material_property_names = 'D'
    function = 'D*c_ref/${R}/T'
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c_ref
  []
  [diffusion]
    type = MassDiffusion
    dual_chemical_energy_density = zeta
    chemical_potential = mu
    mobility = M
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    chemical_potential = mu
  []

  # Redox
  [ramp]
    type = ADGenericFunctionMaterial
    prop_names = 'ramp'
    prop_values = 'if(t<${t0},t/${t0},1)'
  []
  [OCP_anode_graphite]
    type = ADParsedMaterial
    f_name = U
    function = 'x:=c/${cmax}; -(122.12*x^6-321.81*x^5+315.59*x^4-141.26*x^3+28.218*x^2-1.9057*x+0.0785)*ramp'
    args = c
    material_property_names = 'ramp'
    block = 'anode'
  []
  [OCP_cathode_NMC111]
    type = ADParsedMaterial
    f_name = U
    function = 'x:=c/${cmax}; (6.0826-6.9922*x+7.1062*x^2-5.4549e-5*exp(124.23*x-114.2593)-2.5947*x^3)*ramp'
    args = c
    material_property_names = 'ramp'
    block = 'cathode'
  []
  [charge_transfer_anode_elyte]
    type = ChargeTransferReaction
    electrode = true
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_a}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'anode_elyte'
  []
  [charge_transfer_elyte_anode]
    type = ChargeTransferReaction
    electrode = false
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_a}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'elyte_anode'
  []
  [charge_transfer_cathode_elyte]
    type = ChargeTransferReaction
    electrode = true
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'cathode_elyte'
  []
  [charge_transfer_elyte_cathode]
    type = ChargeTransferReaction
    electrode = false
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'elyte_cathode'
  []

  # Thermal
  [thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'rho cv kappa'
    prop_values = '${rho} ${cv} ${kappa}'
  []
  [heat_conduction]
    type = HeatConduction
    thermal_energy_density = chi
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
[]

[Postprocessors]
  [V_l]
    type = SideAverageValue
    variable = Phi
    boundary = left
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V_r]
    type = SideAverageValue
    variable = Phi
    boundary = right
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V]
    type = ParsedPostprocessor
    function = 'V_r - V_l'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [in]
    type = FunctionValuePostprocessor
    function = in
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dC]
    type = ParsedPostprocessor
    function = '-dt*in*${width}'
    pp_names = 'dt in'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C]
    type = CumulativeValuePostprocessor
    postprocessor = dC
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [c_a_max]
    type = NodalExtremeValue
    variable = c
    value_type = max
    block = anode
  []
  [c_c_min]
    type = NodalExtremeValue
    variable = c
    value_type = min
    block = cathode
  []
  [mass_a]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = anode
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_e]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = elyte
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = cathode
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill_a]
    type = Terminator
    expression = 'c_a_max >= ${cmax}'
    message = 'Concentration in anode exceeds the maximum allowable value.'
  []
  [kill_c]
    type = Terminator
    expression = 'c_c_min <= ${cmin}'
    message = 'Concentration in cathode is below the minimum allowable value.'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  ignore_variables_for_autoscaling = 'c'

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 20

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    optimal_iterations = 7
    iteration_window = 2
    growth_factor = 1.2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.2
    linear_iteration_ratio = 1000000
  []
  end_time = 100000
[]

[Outputs]
  file_base = 'I_${I}'
  csv = true
  exodus = true
  print_linear_residuals = false
[]
