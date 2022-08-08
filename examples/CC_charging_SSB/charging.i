I = 5e-6 #mA
sigma_a = 1e-2 #mS/mm
sigma_e = 1e-3 #mS/mm
sigma_cp = 1e-4 #mS/mm
sigma_cm = 1e-4 #mS/mm
sigma_ce = 1e-4 #mS/mm

width = 0.03 #mm
in = '${fparse -I/width}'

cmin = 1e-4 #mmol/mm^3
cmax = 1e-3 #mmol/mm^3
D_cp = 5e-7 #mm^2/s
D_ce = 5e-7 #mm^2/s

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0_a = 1e-15 #mA/mm^2
i0_c = 1e-12 #mA/mm^2

[Mesh]
  [battery]
    type = FileMeshGenerator
    file = 'gold/ssb.msh'
  []
  [interfaces]
    type = BreakMeshByBlockGenerator
    input = battery
    add_interface_on_two_sides = true
    split_interface = true
  []
[]

[Variables]
  [Phi_cp]
    block = cp
  []
  [Phi_cm]
    block = cm
  []
  [Phi_ce]
    block = cm
  []
  [Phi_e]
    block = e
  []
  [Phi_a]
    block = a
  []
  [c]
    block = 'cp cm'
  []
[]

[ICs]
  [c_e]
    type = ConstantIC
    variable = c
    value = ${cmin}
    block = 'cm'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${cmax}
    block = 'cp'
  []
[]

[AuxVariables]
  [T]
    initial_condition = ${T0}
  []
[]

[Kernels]
  [charge_balance_cp]
    type = RankOneDivergence
    variable = Phi_cp
    vector = i_cp
    block = 'cp'
  []
  [charge_balance_cm]
    type = RankOneDivergence
    variable = Phi_cm
    vector = i_cm
    block = 'cm'
  []
  [charge_balance_ce]
    type = RankOneDivergence
    variable = Phi_ce
    vector = i_ce
    block = 'cm'
  []
  [charge_balance_e]
    type = RankOneDivergence
    variable = Phi_e
    vector = i_e
    block = 'e'
  []
  [charge_balance_a]
    type = RankOneDivergence
    variable = Phi_a
    vector = i_a
    block = 'a'
  []
  [mass_balance_1]
    type = MaterialSource
    variable = c
    prop = mu
    block = 'cp cm'
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = J
    block = 'cp cm'
  []
[]

[InterfaceKernels]
  [current_a_e]
    type = MaterialInterfaceNeumannBC
    variable = Phi_a
    neighbor_var = Phi_e
    prop = ibv_a_e
    factor = 1
    boundary = 'a_e'
  []
  [current_e_a]
    type = MaterialInterfaceNeumannBC
    variable = Phi_e
    neighbor_var = Phi_a
    prop = ibv_a_e
    factor = -1
    boundary = 'e_a'
  []
  [current_ce_cp]
    type = MaterialInterfaceNeumannBC
    variable = Phi_ce
    neighbor_var = Phi_cp
    prop = ibv_ce_cp
    factor = 1
    boundary = 'ce_cp'
  []
  [current_cp_ce]
    type = MaterialInterfaceNeumannBC
    variable = Phi_cp
    neighbor_var = Phi_ce
    prop = ibv_ce_cp
    factor = -1
    boundary = 'cp_ce'
  []
  [mass_flux_ce_cp]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = jbv_ce_cp
    factor = 1
    boundary = 'ce_cp'
  []
  [mass_flux_cp_ce]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = jbv_cp_ce
    factor = -1
    boundary = 'cp_ce'
  []
  [continuity_cm_cp]
    type = InterfaceContinuity
    variable = Phi_cm
    neighbor_var = Phi_cp
    penalty = 1e-3
    boundary = 'cm_cp'
  []
  [continuity_ce_e]
    type = InterfaceContinuity
    variable = Phi_ce
    neighbor_var = Phi_e
    penalty = 1e-3
    boundary = 'ce_e'
  []
[]

[BCs]
  [right]
    type = FunctionNeumannBC
    variable = Phi_a
    boundary = right
    function = '${in}'
  []
  [left]
    type = DirichletBC
    variable = Phi_cm
    boundary = left
    value = 0
  []
[]

[Materials]
  # Electrodynamics
  [electric_constants_anode]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_a}'
    block = anode
  []
  [electric_constants_elyte]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_e}'
    block = elyte
  []
  [electric_constants_cathode]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_c}'
    block = cathode
  []
  [polarization]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi
    energy_densities = 'psi_e'
  []

  # Chemical reactions
  [diffusivity_anode]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D_a} ${D_a} ${D_a}'
    block = 'anode'
  []
  [diffusivity_elyte]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D_e} ${D_e} ${D_e}'
    block = 'elyte'
  []
  [diffusivity_cathode]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D_c} ${D_c} ${D_c}'
    block = 'cathode'
  []
  [viscous_mass_transport]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
  []
  [diffusion]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    energy_densities = 'psi_m'
    dissipation_densities = 'delta_c'
    concentration = c
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c
  []

  # Redox
  [ramp]
    type = ADGenericFunctionMaterial
    prop_names = 'ramp'
    prop_values = 'if(t<1,t,1)'
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
    charge_transfer_mass_flux = Je
    electric_potential = Phi
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
    charge_transfer_mass_flux = Je
    electric_potential = Phi
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
    charge_transfer_mass_flux = Je
    electric_potential = Phi
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
    charge_transfer_mass_flux = Je
    electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'elyte_cathode'
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
  [C_rate]
    type = ADSideIntegralMaterialProperty
    property = ie
    boundary = cathode_elyte
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
    function = 'dt*C_rate'
    pp_names = 'dt C_rate'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C]
    type = CumulativeValuePostprocessor
    postprocessor = dC
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [cmax_a]
    type = NodalExtremeValue
    variable = c
    value_type = max
    block = anode
  []
  [cmin_c]
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
    expression = 'cmax_a >= ${cmax}'
    message = 'Concentration in anode exceeds the maximum allowable value.'
  []
  [kill_c]
    type = Terminator
    expression = 'cmin_c <= ${cmin}'
    message = 'Concentration in cathode is below the minimum allowable value.'
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

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    optimal_iterations = 7
    iteration_window = 1
    growth_factor = 1.2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.2
  []
  end_time = 100000
[]

[Outputs]
  file_base = 'I_${I}'
  csv = true
  exodus = true
  print_linear_residuals = false
[]
