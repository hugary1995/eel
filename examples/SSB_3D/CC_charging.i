I = 0.005 #mA
width = 0.05 #mm
in = '${fparse -I/width/width}'
t0 = '${fparse -1e-2/in}'

sigma_a = 0.2 #mS/mm
sigma_e = 0.1 #mS/mm
sigma_cp = 0.05 #mS/mm
sigma_ca = 0.2 #mS/mm
sigma_cm = 0.05 #mS/mm

Phi_penalty = 10

cmin_a = 1e-4 #mmol/mm^3
cmax_a = 1e-3 #mmol/mm^3
c_e = 5e-4 #mmol/mm^3
cmax_c = 1e-3 #mmol/mm^3
c_ref_entropy = 5e-5
D_cp = 5e-5 #mm^2/s
D_cm = 1e-4 #mm^2/s
D_a = 5e-4 #mm^2/s
D_e = 1e-4 #mm^2/s

c_penalty = 1

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0_a = 1e-1 #mA/mm^2
i0_c = 1e-1 #mA/mm^2

E_cp = 6e4
E_cm = 5e4
E_e = 5e4
E_a = 1e5
nu_cp = 0.3
nu_cm = 0.25
nu_e = 0.25
nu_a = 0.3

u_penalty = 1e8

Omega = 140
beta = 1e-4
CTE = 1e-5

rho = 2.5e-9 #Mg/mm^3
cv = 2.7e8 #mJ/Mg/K
kappa = 2e-4 #mJ/mm/K/s
htc = 9.5e-3

T_penalty = 1

[GlobalParams]
  energy_densities = 'dot(psi_m) dot(psi_c) chi q q_ca zeta'
  deformation_gradient = F
  mechanical_deformation_gradient = Fm
  eigen_deformation_gradient = Fg
  swelling_deformation_gradient = Fs
  thermal_deformation_gradient = Ft
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [battery]
    type = FileMeshGenerator
    file = '../coarse.e'
  []
  [scale]
    type = TransformGenerator
    input = battery
    transform = SCALE
    vector_value = '1e-3 1e-3 1e-3' #um to mm
  []
  [cathode_particle]
    type = RenameBlockGenerator
    input = scale
    old_block = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44'
    new_block = 'cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp cp'
  []
  [cathode_matrix]
    type = RenameBlockGenerator
    input = cathode_particle
    old_block = '48'
    new_block = 'cm'
  []
  [elyte]
    type = RenameBlockGenerator
    input = cathode_matrix
    old_block = 49
    new_block = 'e'
  []
  [anode]
    type = RenameBlockGenerator
    input = elyte
    old_block = 50
    new_block = 'a'
  []
  [interfaces]
    type = BreakMeshByBlockGenerator
    input = anode
    add_interface_on_two_sides = true
    split_interface = true
  []
  [sidesets]
    type = SideSetsFromNormalsGenerator
    input = interfaces
    normals = '-1 0 0 1 0 0 0 -1 0 0 1 0 0 0 -1 0 0 1'
    new_boundary = 'left right bottom top back front'
  []
  use_displaced_mesh = false
[]

[Variables]
  [Phi_ca]
    block = cm
  []
  [Phi]
  []
  [c]
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[AuxVariables]
  [c_ref]
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
      scalar_type = Hydrostatic
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [Js]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoScalarAux
      rank_two_tensor = Fs
      scalar_type = ThirdInvariant
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [Jt]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoScalarAux
      rank_two_tensor = Ft
      scalar_type = ThirdInvariant
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [Phi0]
  []
[]

[ICs]
  [c_a]
    type = ConstantIC
    variable = c
    value = ${cmin_a}
    block = 'a'
  []
  [c_e]
    type = ConstantIC
    variable = c
    value = ${c_e}
    block = 'cm e'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${cmax_c}
    block = 'cp'
  []
  [c_ref_a]
    type = ConstantIC
    variable = c_ref
    value = ${cmin_a}
    block = 'a'
  []
  [c_ref_e]
    type = ConstantIC
    variable = c_ref
    value = ${c_e}
    block = 'cm e'
  []
  [c_ref_c]
    type = ConstantIC
    variable = c_ref
    value = ${cmax_c}
    block = 'cp'
  []
[]

[Kernels]
  # Charge balance
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  [charge_balance_ca]
    type = RankOneDivergence
    variable = Phi_ca
    vector = i_ca
    block = cm
  []
  # Mass balance
  [mass_balance_1]
    type = TimeDerivative
    variable = c
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = j
  []
  # Momentum balance
  [momentum_balance_x]
    type = RankTwoDivergence
    variable = disp_x
    component = 0
    tensor = pk1
    factor = -1
  []
  [momentum_balance_y]
    type = RankTwoDivergence
    variable = disp_y
    component = 1
    tensor = pk1
    factor = -1
  []
  [momentum_balance_z]
    type = RankTwoDivergence
    variable = disp_z
    component = 2
    tensor = pk1
    factor = -1
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
    boundary = 'e_a cp_cm'
  []
  [positive_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    boundary = 'a_e cm_cp'
  []
  [negative_mass]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = je
    factor = -1
    boundary = 'e_a cp_cm'
  []
  [positive_mass]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = je
    factor = 1
    boundary = 'a_e cm_cp'
  []
  [heat]
    type = MaterialInterfaceNeumannBC
    variable = T
    neighbor_var = T
    prop = he
    factor = 1
    boundary = 'a_e cm_cp e_a cp_cm'
  []
  [continuity_c]
    type = InterfaceContinuity
    variable = c
    neighbor_var = c
    penalty = ${c_penalty}
    boundary = 'cm_e'
  []
  [continuity_Phi_ca]
    type = InterfaceContinuity
    variable = Phi_ca
    neighbor_var = Phi
    penalty = ${Phi_penalty}
    boundary = 'cm_cp'
  []
  [continuity_Phi]
    type = InterfaceContinuity
    variable = Phi
    neighbor_var = Phi
    penalty = ${Phi_penalty}
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
  [continuity_disp_z]
    type = InterfaceContinuity
    variable = disp_z
    neighbor_var = disp_z
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

[Functions]
  [in]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${in}'
  []
[]

[BCs]
  [current]
    type = FunctionNeumannBC
    variable = Phi
    boundary = right
    function = in
  []
  [potential]
    type = DirichletBC
    variable = Phi_ca
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
    boundary = 'bottom'
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    value = 0
    boundary = 'back'
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = 'left right'
    value = -1
    boundary_material = qconv
  []
[]

[Constraints]
  [ev_y]
    type = EqualValueBoundaryConstraint
    variable = disp_y
    penalty = ${u_penalty}
    secondary = top
  []
  [ev_z]
    type = EqualValueBoundaryConstraint
    variable = disp_z
    penalty = ${u_penalty}
    secondary = front
  []
[]

[Materials]
  # Electrodynamics
  [conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'sigma'
    subdomain_to_prop_value = 'a ${sigma_a} e ${sigma_e} cm ${sigma_cm} cp ${sigma_cp}'
  []
  [conductivity_ca]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'sigma_ca'
    subdomain_to_prop_value = 'cm ${sigma_ca}'
    block = cm
  []
  [charge_transport]
    type = BulkChargeTransport
    electrical_energy_density = q
    electric_potential = Phi
    electric_conductivity = sigma
    temperature = T
  []
  [charge_transport_ca]
    type = BulkChargeTransport
    electrical_energy_density = q_ca
    electric_potential = Phi_ca
    electric_conductivity = sigma_ca
    temperature = T
    block = cm
  []
  [current_density]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
    output_properties = i
    outputs = exodus
  []
  [current_density_ca]
    type = CurrentDensity
    current_density = i_ca
    electric_potential = Phi_ca
    output_properties = i_ca
    outputs = exodus
    block = cm
  []

  # Chemical reactions
  [diffusivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'D'
    subdomain_to_prop_value = 'a ${D_a} e ${D_e} cm ${D_cm} cp ${D_cp}'
  []
  [mobility]
    type = ADParsedMaterial
    f_name = M
    args = 'c_ref T_ref'
    material_property_names = 'D'
    function = 'D*c_ref/${R}/T_ref'
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T_ref
    reference_concentration = ${c_ref_entropy}
  []
  [chemical_potential]
    type = ChemicalPotential
    chemical_potential = mu
    concentration = c
    energy_densities = 'dot(psi_m) dot(psi_c) chi q q_ca zeta m'
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
    outputs = exodus
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
    function = 'x:=c/${cmax_a}; 2.77e-4*x^2-0.0069*x+0.0785'
    # function = 'x:=c/${cmax_a}; -(122.12*x^6-321.81*x^5+315.59*x^4-141.26*x^3+28.218*x^2-1.9057*x+0.0785)*ramp'
    args = c
    material_property_names = 'ramp'
    block = 'a'
  []
  [OCP_cathode_NMC111]
    type = ADParsedMaterial
    f_name = U
    function = 'x:=c/${cmax_c}; (6.0826-6.9922*x+7.1062*x^2-5.4549e-5*exp(124.23*x-114.2593)-2.5947*x^3)*ramp'
    args = c
    material_property_names = 'ramp'
    block = 'cp'
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
    boundary = 'a_e'
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
    boundary = 'e_a'
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
    boundary = 'cp_cm'
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
    boundary = 'cm_cp'
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
    output_properties = h
    outputs = exodus
  []
  [heat_source]
    type = HeatSource
    heat_source = r
    temperature = T
    output_properties = r
    outputs = exodus
  []
  [conv]
    type = ADParsedMaterial
    f_name = qconv
    function = '${htc}*(T-T_ref)'
    args = 'T T_ref'
    boundary = 'left right'
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
  [swelling_coefficient]
    type = ADGenericConstantMaterial
    prop_names = 'beta'
    prop_values = '${beta}'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentration = c
    reference_concentration = c_ref
    molar_volume = ${Omega}
    swelling_coefficient = beta
  []
  [thermal_expansion]
    type = ThermalDeformationGradient
    temperature = T
    reference_temperature = T_ref
    CTE = ${CTE}
  []
  [defgrad]
    type = MechanicalDeformationGradient
  []
  [neohookean]
    type = NeoHookeanSolid
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
    concentration = c
    temperature = T
    non_swelling_pressure = p
    output_properties = 'p'
    outputs = exodus
  []
  [pk1]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    deformation_gradient_rate = dot(F)
  []
[]

[Postprocessors]
  [V_l]
    type = SideAverageValue
    variable = Phi_ca
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
    function = 'V_l - V_r'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [I]
    type = ADSideIntegralMaterialProperty
    property = i
    component = 0
    boundary = right
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dC]
    type = ParsedPostprocessor
    function = 'dt*I'
    pp_names = 'dt I'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C]
    type = CumulativeValuePostprocessor
    postprocessor = dC
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill_V]
    type = Terminator
    expression = 'V >= 4.6'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 301 0.7 ext+i PMIS 4 2 0.4'
  automatic_scaling = true
  ignore_variables_for_autoscaling = 'T'
  verbose = true
  line_search = none

  l_max_its = 300
  l_tol = 1e-6
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-9
  nl_max_its = 12

  [Predictor]
    type = SimplePredictor
    scale = 1
  []
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = '${fparse t0/50}'
    optimal_iterations = 6
    iteration_window = 1
    growth_factor = 1.2
    cutback_factor = 0.2
    cutback_factor_at_failure = 0.1
    linear_iteration_ratio = 100
  []
  end_time = 10000
[]

[Outputs]
  file_base = '${outname}_CC_charging'
  exodus = true
  csv = true
  print_linear_residuals = false
  checkpoint = true
[]
