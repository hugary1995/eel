R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

in = '${fparse 1e3/pi/34^2}'

sigma_con = 1

c_ref = 1e-3
c_ref_ent = 1e-6
M_con = 1e-1

kappa_con = 398 #mJ/mm/K/s
kappa_air = 3.98 #mJ/mm/K/s
kappa_ins = 0.29 #mJ/mm/K/s
kappa_jac = 0.39 #mJ/mm/K/s

E_con = 1.1e5
E_air = 1e2
E_ins = 6e2
E_jac = 3e2
nu_con = 0.32
nu_air = 0.25
nu_ins = 0.4
nu_jac = 0.3

CTE = 1e-5

htc = 1e1

[GlobalParams]
  energy_densities = 'q dot(psi_c) zeta m chi dot(psi_m)'
  deformation_gradient = F
  mechanical_deformation_gradient = Fm
  eigen_deformation_gradient = Fg
  thermal_deformation_gradient = Ft
[]

[Problem]
  kernel_coverage_check = false
  material_coverage_check = false
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/cable.msh'
  []
  use_displaced_mesh = false
[]

[Variables]
  [Phi]
    block = 'conductor'
  []
  [c]
    initial_condition = ${c_ref}
    block = 'conductor'
  []
  [T]
    initial_condition = ${T0}
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
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
[]

[Functions]
  [current_density]
    type = PiecewiseLinear
    x = '0 100'
    y = '0 ${in}'
  []
[]

[Kernels]
  # Charge balance
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
    block = 'conductor'
  []
  # Mass balance
  [mass_balance_1]
    type = TimeDerivative
    variable = c
    block = 'conductor'
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = j
    block = 'conductor'
  []
  # Energy balance
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
[]

[BCs]
  [current]
    type = FunctionNeumannBC
    variable = Phi
    boundary = 'conductor_top'
    function = current_density
  []
  [Phi_ref]
    type = DirichletBC
    variable = Phi
    boundary = 'conductor_bottom'
    value = 0
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = 'outer'
    value = -1
    boundary_material = qconv
  []
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'center piny'
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'center pinx'
    value = 0
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'conductor_bottom air_bottom insulator_bottom jacket_bottom'
    value = 0
  []
[]

[Materials]
  # Electrodynamics
  [conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'sigma'
    subdomain_to_prop_value = 'conductor ${sigma_con}'
    block = 'conductor'
  []
  [charge_transport]
    type = BulkChargeTransport
    electrical_energy_density = q
    electric_potential = Phi
    electric_conductivity = sigma
    temperature = T
    block = 'conductor'
  []
  [current_density]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
    block = 'conductor'
  []

  # Chemistry
  [mobility]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'M'
    subdomain_to_prop_value = 'conductor ${M_con}'
    block = 'conductor'
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = ${c_ref_ent}
    block = 'conductor'
  []
  [chemical_potential]
    type = ChemicalPotential
    chemical_potential = mu
    concentration = c
    block = 'conductor'
  []
  [diffusion]
    type = MassDiffusion
    dual_chemical_energy_density = zeta
    chemical_potential = mu
    mobility = M
    block = 'conductor'
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    chemical_potential = mu
    block = 'conductor'
  []

  # Migration
  [migration]
    type = Migration
    electrochemical_energy_density = m
    electric_potential = Phi
    chemical_potential = mu
    electric_conductivity = sigma
    faraday_constant = ${F}
    block = 'conductor'
  []
  [migration_flux]
    type = MassFlux
    mass_flux = jm
    energy_densities = 'm'
    chemical_potential = mu
    block = 'conductor'
  []

  # Thermal
  [heat_conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'kappa'
    subdomain_to_prop_value = 'conductor ${kappa_con} air ${kappa_air} insulator ${kappa_ins} jacket ${kappa_jac}'
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
  []
  [heat_source]
    type = VariationalHeatSource
    heat_source = r
    temperature = T
  []
  [qconv]
    type = ADParsedMaterial
    f_name = qconv
    function = 'htc*(T-T_inf)'
    args = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc} ${T0}'
    boundary = 'outer'
  []

  # Mechanics
  [youngs_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'lambda'
    subdomain_to_prop_value = 'conductor ${fparse E_con*nu_con/(1+nu_con)/(1-2*nu_con)} air ${fparse E_air*nu_air/(1+nu_air)/(1-2*nu_air)} insulator ${fparse E_ins*nu_ins/(1+nu_ins)/(1-2*nu_ins)} jacket ${fparse E_jac*nu_jac/(1+nu_jac)/(1-2*nu_jac)}'
  []
  [poissons_ratio]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = 'conductor ${fparse E_con/2/(1+nu_con)} air ${fparse E_air/2/(1+nu_air)} insulator ${fparse E_ins/2/(1+nu_ins)} jacket ${fparse E_jac/2/(1+nu_jac)}'
  []
  [thermal_expansion]
    type = ThermalDeformationGradient
    temperature = T
    reference_temperature = ${T0}
    CTE = ${CTE}
  []
  [defgrad]
    type = MechanicalDeformationGradient
    displacements = 'disp_x disp_y disp_z'
  []
  [neohookean]
    type = NeoHookeanSolid
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
    concentration = c
    temperature = T
  []
  [pk1]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = pk1
    deformation_gradient_rate = dot(F)
  []
[]

[Postprocessors]
  [T_max]
    type = NodalExtremeValue
    variable = T
    block = 'conductor'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 301 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true
  ignore_variables_for_autoscaling = 'T c'
  verbose = true
  line_search = none

  l_max_its = 300
  l_tol = 1e-6
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 12

  [Predictor]
    type = SimplePredictor
    scale = 1
  []
  [TimeStepper]
    type = FunctionDT
    function = 'if(t<100,10,100)'
  []
  end_time = 100
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
