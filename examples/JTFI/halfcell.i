I = 0.005 #mA
width = 0.05 #mm
in = '${fparse -I/width}'
t0 = '${fparse -1e-2/in}'

sigma_e = 0.1 #mS/mm
sigma_cp = 0.05 #mS/mm

Phi_penalty = 10

c_e = 5e-4 #mmol/mm^3
cmax_c = 1e-3 #mmol/mm^3
c_ref_entropy = 5e-5
D_cp = 5e-5 #mm^2/s
D_e = 1e-4 #mm^2/s

c_penalty = 1

R = 8.3145 #mJ/mmol/K
T0 = 300 #K

E_cp = 6e4
E_e = 5e4
nu_cp = 0.3
nu_e = 0.25

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
  energy_densities = 'dot(psi_m) dot(psi_c) chi q zeta'
  deformation_gradient = F
  mechanical_deformation_gradient = Fm
  eigen_deformation_gradient = Fg
  swelling_deformation_gradient = Fs
  thermal_deformation_gradient = Ft
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [cell]
    type = FileMeshGenerator
    file = 'gold/ssb_60x40_micron.exo'
  []
  [interfaces]
    type = BreakMeshByBlockGenerator
    input = cell
  []
  use_displaced_mesh = false
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
      scalar_type = MaxPrincipal
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[ICs]
  [c_e]
    type = ConstantIC
    variable = c
    value = ${c_e}
    block = 'matrix'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${cmax_c}
    block = 'particles'
  []
  [c_ref_e]
    type = ConstantIC
    variable = c_ref
    value = ${c_e}
    block = 'matrix'
  []
  [c_ref_c]
    type = ConstantIC
    variable = c_ref
    value = ${cmax_c}
    block = 'particles'
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
  [continuity_Phi]
    type = InterfaceContinuity
    variable = Phi
    neighbor_var = Phi
    penalty = ${Phi_penalty}
    boundary = 'interface'
  []
  [continuity_c]
    type = InterfaceContinuity
    variable = c
    neighbor_var = c
    penalty = ${c_penalty}
    boundary = 'interface'
  []
  [continuity_T]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T
    penalty = ${T_penalty}
    boundary = 'interface'
  []
  [continuity_disp_x]
    type = InterfaceContinuity
    variable = disp_x
    neighbor_var = disp_x
    penalty = ${u_penalty}
    boundary = 'interface'
  []
  [continuity_disp_y]
    type = InterfaceContinuity
    variable = disp_y
    neighbor_var = disp_y
    penalty = ${u_penalty}
    boundary = 'interface'
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
    boundary = right_surf
    function = in
  []
  [potential]
    type = DirichletBC
    variable = Phi
    boundary = left_surf
    value = 0
  []
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'left_surf right_surf'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'bot_surf'
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = 'left_surf right_surf'
    value = -1
    boundary_material = qconv
  []
[]

[Constraints]
  [ev_y]
    type = EqualValueBoundaryConstraint
    variable = disp_y
    penalty = ${u_penalty}
    secondary = 'top_surf'
  []
[]

[Materials]
  # Electrodynamics
  # [conductivity_e]
  #   type = ADGenericConstantMaterial
  #   prop_names = 'sigma'
  #   prop_values = '${sigma_e}'
  #   block = 'matrix'
  # []
  # [conductivity_cp]
  #   type = ADGenericConstantMaterial
  #   prop_names = 'sigma'
  #   prop_values = '${sigma_cp}'
  #   block = 'particles'
  # []
  [conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = sigma
    subdomain_to_prop_value = 'matrix ${sigma_e} particles ${sigma_cp}'
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
    output_properties = i
    outputs = exodus
  []

  # Chemical reactions
  [diffusivity_e]
    type = ADGenericConstantMaterial
    prop_names = 'D'
    prop_values = '${D_e}'
    block = 'matrix'
  []
  [diffusivity_cp]
    type = ADGenericConstantMaterial
    prop_names = 'D'
    prop_values = '${D_cp}'
    block = 'particles'
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
    reference_chemical_potential = 1e3
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

  # Thermal
  [thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'rho cv kappa'
    prop_values = '${rho} ${cv} ${kappa}'
  []
  [heat_conduction]
    type = FourierPotential
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
    type = VariationalHeatSource
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
    boundary = 'left_surf right_surf'
  []

  # Mechanical
  [stiffness_cp]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_cp*nu_cp/(1+nu_cp)/(1-2*nu_cp)} ${fparse E_cp/2/(1+nu_cp)}'
    block = particles
  []
  [stiffness_e]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_e*nu_e/(1+nu_e)/(1-2*nu_e)} ${fparse E_e/2/(1+nu_e)}'
    block = matrix
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

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
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
  end_time = 100
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
