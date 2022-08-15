I = 1e-4 #mA
width = 0.03 #mm
in = '${fparse -I/width}'

sigma_a = 1e0 #mS/mm
sigma_e = 1e-1 #mS/mm
sigma_c = 1e-2 #mS/mm

l0 = 0
l1 = 0.04
l2 = 0.07
l3 = 0.12

cmin = 1e-4 #mmol/mm^3
cmax = 1e-3 #mmol/mm^3
D_a = 1e-4 #mm^2/s
D_e = 1e-4 #mm^2/s
D_c = 5e-5 #mm^2/s

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0_a = 1e-4 #mA/mm^2
i0_c = 1e-1 #mA/mm^2

E_c = 1e5
E_e = 1e4
E_a = 2e5
nu_c = 0.3
nu_e = 0.25
nu_a = 0.3

Omega = 60
beta = 1

CTE = 1e-5

u_penalty = 1e8

rho = 2.5e-9 #Mg/mm^3
cv = 2.7e6 #mJ/Mg/K
kappa = 2e-2 #mJ/mm/K/s

T_penalty = 2

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

  [disp_x]
  []
  [disp_y]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[ICs]
  [c_e]
    type = ConstantIC
    variable = c
    value = ${cmin}
    block = 'anode elyte'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${cmax}
    block = 'cathode'
  []
[]

[AuxVariables]
  [q]
  []
  [c_ref]
    initial_condition = ${cmin}
  []
  [T_ref]
    initial_condition = ${T0}
  []
  [stress]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoScalarAux
      rank_two_tensor = pk1
      scalar_type = VonMisesStress
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
    save_in = q
  []
  [mass_balance_1]
    type = MaterialSource
    variable = c
    prop = mu
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = J
  []
  [momentum_balance_x]
    type = RankTwoDivergence
    variable = disp_x
    component = 0
    tensor = pk1
  []
  [momentum_balance_y]
    type = RankTwoDivergence
    variable = disp_y
    component = 1
    tensor = pk1
  []
  [energy_balance_1]
    type = ADHeatConductionTimeDerivative
    variable = T
    density_name = rho
    specific_heat = cv
  []
  [energy_balance_2]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = kappa
  []
  [heat_source_cp]
    type = MaterialSource
    variable = T
    prop = jh
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
    variable = c
    neighbor_var = c
    prop = Je
    factor = -1
    boundary = 'elyte_anode cathode_elyte'
  []
  [positive_mass]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = Je
    factor = 1
    boundary = 'anode_elyte elyte_cathode'
  []
  [continuity_disp_x]
    type = InterfaceContinuity
    variable = disp_x
    neighbor_var = disp_x
    penalty = ${u_penalty}
    boundary = 'anode_elyte elyte_cathode'
  []
  [continuity_disp_y]
    type = InterfaceContinuity
    variable = disp_y
    neighbor_var = disp_y
    penalty = ${u_penalty}
    boundary = 'anode_elyte elyte_cathode'
  []
  [continuity_T]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T
    penalty = ${T_penalty}
    boundary = 'anode_elyte elyte_cathode'
  []
[]

[BCs]
  [left]
    type = FunctionNeumannBC
    variable = Phi
    boundary = left
    function = '${in}'
  []
  [right]
    type = DirichletBC
    variable = Phi
    boundary = right
    value = 0
  []
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'left right'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'left right'
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
    charge_transfer_mass_flux = Je
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
    charge_transfer_mass_flux = Je
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
    charge_transfer_mass_flux = Je
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
  [joule_heating]
    type = JouleHeating
    electric_potential = Phi
    electric_conductivity = sigma
    joule_heating = jh
  []

  # Mechanical
  [stiffness_c]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_c*nu_c/(1+nu_c)/(1-2*nu_c)} ${fparse E_c/2/(1+nu_c)}'
    block = cathode
  []
  [stiffness_e]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_e*nu_e/(1+nu_e)/(1-2*nu_e)} ${fparse E_e/2/(1+nu_e)}'
    block = elyte
  []
  [stiffness_a]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_a*nu_a/(1+nu_a)/(1-2*nu_a)} ${fparse E_a/2/(1+nu_a)}'
    block = anode
  []
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'beta'
    prop_values = '${beta}'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentrations = c
    reference_concentrations = c_ref
    molar_volumes = ${Omega}
    swelling_coefficient = beta
  []
  [thermal_expansion]
    type = ThermalDeformationGradient
    temperature = T
    reference_temperature = T_ref
    CTE = ${CTE}
  []
  [defgrad]
    type = DeformationGradient
    displacements = 'disp_x disp_y'
  []
  [neohookean]
    type = NeoHookeanElasticEnergyDensity
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
  []
  [pk1]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    energy_densities = 'psi_m psi_e'
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
  nl_abs_tol = 1e-10
  nl_max_its = 20

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    optimal_iterations = 6
    iteration_window = 2
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
