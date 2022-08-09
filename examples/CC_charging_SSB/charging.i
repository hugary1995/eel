I = 5e-3 #mA
sigma_a = 1e0 #mS/mm
sigma_e = 1e-1 #mS/mm
sigma_cp = 1e-2 #mS/mm
sigma_cm = 1e-2 #mS/mm
sigma_ce = 5e-2 #mS/mm

c_penalty = 1

width = 0.03 #mm
in = '${fparse -I/width}'

cmin = 1e-4 #mmol/mm^3
cmax = 1e-3 #mmol/mm^3
D_cp = 5e-5 #mm^2/s
D_ce = 1e-4 #mm^2/s

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0_a = 1e-4 #mA/mm^2
i0_c = 1e-1 #mA/mm^2

E_cp = 1e5
E_cm = 5e4
E_e = 1e4
E_a = 2e5
nu_cp = 0.3
nu_cm = 0.25
nu_e = 0.25
nu_a = 0.3

Omega = 60
beta = 1

CTE = 1e-5

u_penalty = 1e8

rho = 2.5e-9 #Mg/mm^3
cv = 2.7e8 #mJ/Mg/K
kappa = 2e-5 #mJ/mm/K/s

T_penalty = 1e-2

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
  [disp_x]
  []
  [disp_y]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[ICs]
  [c_ce]
    type = ConstantIC
    variable = c
    value = ${cmin}
    block = 'cm'
  []
  [c_cp]
    type = ConstantIC
    variable = c
    value = ${cmax}
    block = 'cp'
  []
[]

[AuxVariables]
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
    prop = jh_cp
    coefficient = -1
    block = cp
  []
  [heat_source_cm]
    type = MaterialSource
    variable = T
    prop = jh_cm
    coefficient = -1
    block = cm
  []
  [heat_source_ce]
    type = MaterialSource
    variable = T
    prop = jh_ce
    coefficient = -1
    block = cm
  []
  [heat_source_e]
    type = MaterialSource
    variable = T
    prop = jh_e
    coefficient = -1
    block = e
  []
  [heat_source_a]
    type = MaterialSource
    variable = T
    prop = jh_a
    coefficient = -1
    block = a
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
    boundary = 'cm_cp'
  []
  [current_cp_ce]
    type = MaterialInterfaceNeumannBC
    variable = Phi_cp
    neighbor_var = Phi_ce
    prop = ibv_ce_cp
    factor = -1
    boundary = 'cp_cm'
  []
  [mass_flux_cp_ce]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = jbv_ce_cp
    factor = -1
    boundary = 'cp_cm'
  []
  [continuity_cm_cp]
    type = InterfaceContinuity
    variable = Phi_cm
    neighbor_var = Phi_cp
    penalty = ${c_penalty}
    boundary = 'cm_cp'
  []
  [continuity_ce_e]
    type = InterfaceContinuity
    variable = Phi_ce
    neighbor_var = Phi_e
    penalty = ${c_penalty}
    boundary = 'cm_e'
  []
  [continuity_disp_x]
    type = InterfaceContinuity
    variable = disp_x
    neighbor_var = disp_x
    penalty = ${u_penalty}
    boundary = 'cp_cm cm_e e_a'
  []
  [continuity_disp_y]
    type = InterfaceContinuity
    variable = disp_y
    neighbor_var = disp_y
    penalty = ${u_penalty}
    boundary = 'cp_cm cm_e e_a'
  []
  [continuity_T]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T
    penalty = ${T_penalty}
    boundary = 'cp_cm cm_e e_a'
  []
[]

[BCs]
  [current_right]
    type = FunctionNeumannBC
    variable = Phi_a
    boundary = right
    function = '${in}'
  []
  [potential_left]
    type = DirichletBC
    variable = Phi_cm
    boundary = left
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
  [electric_constants_cp]
    type = ADGenericConstantMaterial
    prop_names = 'sigma_cp'
    prop_values = '${sigma_cp}'
    block = cp
  []
  [electric_constants_cm]
    type = ADGenericConstantMaterial
    prop_names = 'sigma_cm'
    prop_values = '${sigma_cm}'
    block = cm
  []
  [electric_constants_ce]
    type = ADGenericConstantMaterial
    prop_names = 'sigma_ce'
    prop_values = '${sigma_ce}'
    block = cm
  []
  [electric_constants_e]
    type = ADGenericConstantMaterial
    prop_names = 'sigma_e'
    prop_values = '${sigma_e}'
    block = e
  []
  [electric_constants_a]
    type = ADGenericConstantMaterial
    prop_names = 'sigma_a'
    prop_values = '${sigma_a}'
    block = a
  []
  [polarization_cp]
    type = Polarization
    electrical_energy_density = psi_e_cp
    electric_potential = Phi_cp
    electric_conductivity = sigma_cp
    block = cp
  []
  [polarization_cm]
    type = Polarization
    electrical_energy_density = psi_e_cm
    electric_potential = Phi_cm
    electric_conductivity = sigma_cm
    block = cm
  []
  [polarization_ce]
    type = Polarization
    electrical_energy_density = psi_e_ce
    electric_potential = Phi_ce
    electric_conductivity = sigma_ce
    block = cm
  []
  [polarization_e]
    type = Polarization
    electrical_energy_density = psi_e_e
    electric_potential = Phi_e
    electric_conductivity = sigma_e
    block = e
  []
  [polarization_a]
    type = Polarization
    electrical_energy_density = psi_e_a
    electric_potential = Phi_a
    electric_conductivity = sigma_a
    block = a
  []
  [electric_displacement_cp]
    type = ElectricDisplacement
    electric_displacement = i_cp
    electric_potential = Phi_cp
    energy_densities = 'psi_e_cp'
    block = cp
  []
  [electric_displacement_cm]
    type = ElectricDisplacement
    electric_displacement = i_cm
    electric_potential = Phi_cm
    energy_densities = 'psi_e_cm'
    block = cm
  []
  [electric_displacement_ce]
    type = ElectricDisplacement
    electric_displacement = i_ce
    electric_potential = Phi_ce
    energy_densities = 'psi_e_ce'
    block = cm
  []
  [electric_displacement_e]
    type = ElectricDisplacement
    electric_displacement = i_e
    electric_potential = Phi_e
    energy_densities = 'psi_e_e'
    block = e
  []
  [electric_displacement_a]
    type = ElectricDisplacement
    electric_displacement = i_a
    electric_potential = Phi_a
    energy_densities = 'psi_e_a'
    block = a
  []

  # Chemical reactions
  [diffusivity_cp]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D_cp} ${D_cp} ${D_cp}'
    block = 'cp'
  []
  [diffusivity_ce]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D_ce} ${D_ce} ${D_ce}'
    block = 'cm'
  []
  [viscous_mass_transport]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    block = 'cp cm'
  []
  [diffusion]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
    block = 'cp cm'
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    energy_densities = 'psi_m'
    dissipation_densities = 'delta_c'
    concentration = c
    block = 'cp cm'
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c
    block = 'cp cm'
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
    function = '-0.0785*ramp'
    # function = 'x:=c/${cmax}; -(122.12*x^6-321.81*x^5+315.59*x^4-141.26*x^3+28.218*x^2-1.9057*x+0.0785)*ramp'
    # args = c
    material_property_names = 'ramp'
    block = a
  []
  [OCP_cathode_NMC111]
    type = ADParsedMaterial
    f_name = U
    function = 'x:=c/${cmax}; (6.0826-6.9922*x+7.1062*x^2-5.4549e-5*exp(124.23*x-114.2593)-2.5947*x^3)*ramp'
    args = c
    material_property_names = 'ramp'
    block = cp
  []
  [charge_transfer_cp_ce]
    type = ChargeTransferReaction
    electrode = true
    charge_transfer_current_density = ibv_ce_cp
    charge_transfer_mass_flux = jbv_ce_cp
    electric_potential = Phi_cp
    neighbor_electric_potential = Phi_ce
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'cp_cm'
  []
  [charge_transfer_ce_cp]
    type = ChargeTransferReaction
    electrode = false
    charge_transfer_current_density = ibv_ce_cp
    charge_transfer_mass_flux = jbv_ce_cp
    electric_potential = Phi_ce
    neighbor_electric_potential = Phi_cp
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'cm_cp'
  []
  [charge_transfer_a_e]
    type = ChargeTransferReaction
    electrode = true
    charge_transfer_current_density = ibv_a_e
    charge_transfer_mass_flux = jbv_a_e
    electric_potential = Phi_a
    neighbor_electric_potential = Phi_e
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_a}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'a_e'
  []
  [charge_transfer_e_a]
    type = ChargeTransferReaction
    electrode = false
    charge_transfer_current_density = ibv_a_e
    charge_transfer_mass_flux = jbv_a_e
    electric_potential = Phi_e
    neighbor_electric_potential = Phi_a
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_a}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'e_a'
  []

  # Thermal
  [thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'rho cv kappa'
    prop_values = '${rho} ${cv} ${kappa}'
  []
  [joule_heating_cp]
    type = JouleHeating
    electric_potential = Phi_cp
    electric_conductivity = sigma_cp
    joule_heating = jh_cp
    block = cp
  []
  [joule_heating_cm]
    type = JouleHeating
    electric_potential = Phi_cm
    electric_conductivity = sigma_cm
    joule_heating = jh_cm
    block = cm
  []
  [joule_heating_ce]
    type = JouleHeating
    electric_potential = Phi_ce
    electric_conductivity = sigma_ce
    joule_heating = jh_ce
    block = cm
  []
  [joule_heating_e]
    type = JouleHeating
    electric_potential = Phi_e
    electric_conductivity = sigma_e
    joule_heating = jh_e
    block = e
  []
  [joule_heating_a]
    type = JouleHeating
    electric_potential = Phi_a
    electric_conductivity = sigma_a
    joule_heating = jh_a
    block = a
  []

  # Mechanical
  [stiffness_cp]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_cp*nu_cp/(1+nu_cp)/(1-2*nu_cp)} ${fparse E_cp/2/(1+nu_cp)}'
    block = cp
  []
  [stiffness_cm]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_cm*nu_cm/(1+nu_cm)/(1-2*nu_cm)} ${fparse E_cm/2/(1+nu_cm)}'
    block = cm
  []
  [stiffness_e]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_e*nu_e/(1+nu_e)/(1-2*nu_e)} ${fparse E_e/2/(1+nu_e)}'
    block = e
  []
  [stiffness_a]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_a*nu_a/(1+nu_a)/(1-2*nu_a)} ${fparse E_a/2/(1+nu_a)}'
    block = a
  []
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'beta'
    prop_values = '${beta}'
  []
  [swelling_cp]
    type = SwellingDeformationGradient
    concentrations = c
    reference_concentrations = c_ref
    molar_volumes = ${Omega}
    swelling_coefficient = beta
    block = cp
  []
  [swelling_other]
    type = SwellingDeformationGradient
    concentrations = c_ref
    reference_concentrations = c_ref
    molar_volumes = ${Omega}
    swelling_coefficient = beta
    block = 'cm e a'
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
  [pk1_cp]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    energy_densities = 'psi_m psi_e_cp'
    block = cp
  []
  [pk1_cm]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    energy_densities = 'psi_m psi_e_cm psi_e_ce'
    block = cm
  []
  [pk1_e]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    energy_densities = 'psi_m psi_e_e'
    block = e
  []
  [pk1_a]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    energy_densities = 'psi_m psi_e_a'
    block = a
  []
[]

[Postprocessors]
  [V_l]
    type = SideAverageValue
    variable = Phi_cm
    boundary = left
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V_r]
    type = SideAverageValue
    variable = Phi_a
    boundary = right
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V]
    type = ParsedPostprocessor
    function = 'V_l - V_r'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dC]
    type = ParsedPostprocessor
    function = 'dt*${I}'
    pp_names = 'dt'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C]
    type = CumulativeValuePostprocessor
    postprocessor = dC
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [cmin_cp]
    type = NodalExtremeValue
    variable = c
    value_type = min
    block = cp
  []
[]

[UserObjects]
  [kill_cp]
    type = Terminator
    expression = 'cmin_cp <= ${cmin}'
    message = 'Concentration in cathode particle is below the minimum allowable value.'
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
    type = FunctionDT
    function = 'if(t<1, 0.05, 0.01)'
  []
  end_time = 100

  [Quadrature]
    order = CONSTANT
  []
[]

[Outputs]
  csv = true
  exodus = true
  print_linear_residuals = false
[]
