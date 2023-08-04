# bulk
lambda = 1e5
G = 8e4
alpha = -1e-3
Omega = 100
sigma_y = 1e8
n = 5
A = 0 # turn off plasticity
Nr = 0 # turn off nucleation in bulk

c0 = 1
c_ref = 1
T = 800
M = 1e-11
# M = 1e-16
mu0 = 1e3
R = 8.3145
Ly = 1

# GB
alphai = -1e-3
Nri = 1e-6
Mi = 1e-16
# Mi = 1e-6
Gc = 1e40
w = 1
Ei = 1e5
Gi = 8e4
Qvi = 1e4
mu0i = 1e3

# adaptive dt
load = 10
t0 = '${fparse load*60}'
tf = 1e6
dt = '${fparse t0/100}'
dtmax = '${fparse tf/1000}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  energy_densities = 'dot(psi_m) dot(psi_c) Delta_p zeta'
  volumetric_locking_correction = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/hex_n4_h0.025.msh'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = fmg
    add_interface_on_two_sides = true
  []
  use_displaced_mesh = false
[]

[Modules]
  [TensorMechanics]
    [CohesiveZoneMaster]
      [interface]
        boundary = interface
        strain = SMALL
        use_automatic_differentiation = true
      []
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [mu_var]
  []
  [c]
    initial_condition = ${c0}
  []
[]

[AuxVariables]
  [c_ref]
    initial_condition = ${c_ref}
  []
  [T]
    initial_condition = ${T}
  []
  [mu_old]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADMaterialRealAux
      property = mu
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [mui]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADMaterialRealAux
      property = mui
      execute_on = 'INITIAL TIMESTEP_END'
      check_boundary_restricted = false
      boundary = interface
    []
  []
[]

[Kernels]
  [momentum_balance_x]
    type = RankTwoDivergence
    variable = disp_x
    component = 0
    tensor = cauchy
    factor = -1
  []
  [momentum_balance_y]
    type = RankTwoDivergence
    variable = disp_y
    component = 1
    tensor = cauchy
    factor = -1
  []
  [mu]
    type = ADMaterialPropertyValue
    variable = mu_var
    prop_name = mu
  []
  [mass_balance_1]
    type = TimeDerivative
    variable = c
  []
  [mass_balance_2]
    type = MassDiffusionTest
    variable = c
    chemical_potential = mu_var
    mobility = M
  []
  [mass_source]
    type = MaterialSource
    variable = c
    prop = m
    coefficient = -1
  []
[]

[InterfaceKernels]
  [mu]
    type = InterfaceADMaterialPropertyValue
    variable = mu_var
    neighbor_var = mu_var
    mat_prop = mui
    boundary = interface
  []
  [mass]
    type = GBCavitationTransportTest
    variable = c
    neighbor_var = c
    cavity_nucleation_rate = mi
    mobility = Mi
    interface_width = ${w}
    chemical_potential = mu_var
    boundary = interface
  []
  [continuity]
    type = InterfaceContinuity
    variable = c
    neighbor_var = c
    boundary = interface
    penalty = 1e8
  []
[]

[Functions]
  [temporal]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${load}'
  []
  [load_top]
    type = CompositeFunction
    functions = 'temporal'
    scale_factor = 1
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  []
  [force_y]
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 'top'
    function = load_top
  []
  [Periodic]
    [c]
      variable = c
      auto_direction = 'x y'
    []
  []
[]

[Constraints]
  [ev_x]
    type = EqualValueBoundaryConstraint
    variable = disp_x
    secondary = right
    penalty = 1e8
  []
  [ev_y]
    type = EqualValueBoundaryConstraint
    variable = disp_y
    secondary = top
    penalty = 1e8
  []
[]

[Materials]
  #bulk
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nr M mu0'
    prop_values = '${Nr} ${M} ${mu0}'
  []
  [mass_source]
    type = MassSource
    mass_source = m
    chemical_potential = mu
    outputs = exodus
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c_ref
    reference_chemical_potential = mu0
  []
  [chemical_potential]
    type = ChemicalPotentialTest
    chemical_potential = mu
    # energy_densities = 'dot(psi_c)'
    concentration = c
    outputs = exodus
  []
  [varying_youngs_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = lambda
    subdomain_to_prop_value = 'grain_0 ${lambda} grain_3 ${fparse 1.5*lambda} grain_4 ${fparse 0.8*lambda}
                               grain_5 ${fparse 1.1*lambda} grain_6 ${fparse 0.8*lambda}
                               grain_7 ${fparse 1.5*lambda} grain_8 ${fparse 1.2*lambda}'
    outputs = exodus
  []
  [stiffness]
    type = ADGenericConstantMaterial
    prop_names = 'G sigma_y'
    prop_values = '${G} ${sigma_y}'
  []
  [swelling_coefficient]
    type = ADGenericConstantMaterial
    prop_names = 'alpha'
    prop_values = '${alpha}'
  []
  [swelling]
    type = SwellingStrain
    concentration = c
    reference_concentration = c_ref
    molar_volume = ${Omega}
    swelling_coefficient = alpha
    swelling_strain = Es
    # output_properties = 'Es'
    # outputs = 'exodus'
  []
  [strain]
    type = Strain
    strain = E
  []
  [mechanical_strain]
    type = MechanicalStrain
    swelling_strain = Es
    strain = E
    mechanical_strain = Em
    eigen_strain = Eg
  []
  [envelope]
    type = ADDerivativeParsedMaterial
    property_name = Delta_p
    expression = 'sigma_y * ep_dot'
    material_property_names = 'sigma_y ep_dot mu0'
    additional_derivative_symbols = 'ep_dot'
    derivative_order = 2
    compute = false
  []
  [elastic_energy_density]
    type = SDElasticEnergyDensity
    elastic_energy_density = psi_m
    swelling_strain = Es
    strain = E
    plastic_strain = Ep
    mechanical_strain = Em
    equivalent_plastic_strain = ep
    elastic_strain = Ee
    lambda = lambda
    shear_modulus = G
    concentration = c
    creep_exponent = ${n}
    creep_coefficient = ${A}
    plastic_dissipation_material = envelope
    plastic_power_density = Delta_p
  []
  [stress]
    type = SDStress
    cauchy_stress = cauchy
    strain_rate = 'dot(E)'
    outputs = exodus
  []
  [hydrostatic_stress]
    type = ADRankTwoInvariant
    property_name = p
    rank_two_tensor = cauchy
    invariant = Hydrostatic
    outputs = 'exodus'
  []

  # GB
  [interface_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nri Mi Gc Ei Gi mu0i alphai'
    prop_values = '${Nri} ${Mi} ${Gc} ${Ei} ${Gi} ${mu0i} ${alphai}'
    boundary = interface
  []
  [traction_separation]
    type = GBCavitationTest
    activation_energy = ${Qvi}
    cavity_nucleation_rate = mi
    concentration = c
    reference_concentration = c_ref
    reference_chemical_potential = mu0i
    interface_chemical_potential = mui
    critical_energy_release_rate = Gc
    damage = d
    ideal_gas_constant = ${R}
    interface_width = ${w}
    molar_volume = ${Omega}
    reference_nucleation_rate = Nri
    normal_stiffness = Ei
    tangential_stiffness = Gi
    swelling_coefficient = alphai
    temperature = T
    boundary = interface
    stress = cauchy
    # output_properties = 'mui'
    # outputs = exodus
  []

  # strain for post processing
  [strain_yy]
    type = ADRankTwoCartesianComponent
    property_name = Eyy
    rank_two_tensor = E
    index_i = 1
    index_j = 1
  []
  [strain_rate_yy]
    type = ADRankTwoCartesianComponent
    property_name = dot(Eyy)
    rank_two_tensor = dot(E)
    index_i = 1
    index_j = 1
  []
  [creep_strain_yy]
    type = ADRankTwoCartesianComponent
    property_name = Epyy
    rank_two_tensor = Ep
    index_i = 1
    index_j = 1
  []
  [swelling_strain_yy]
    type = ADRankTwoCartesianComponent
    property_name = Esyy
    rank_two_tensor = Es
    index_i = 1
    index_j = 1
  []
[]

[Postprocessors]
  # cavity
  [cavity_density]
    type = ElementAverageValue
    variable = c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [cavity_potential]
    type = ADElementAverageMaterialProperty
    mat_prop = mu
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p]
    type = ADElementAverageMaterialProperty
    mat_prop = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # strain rate
  [dt]
    type = TimestepSize
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [uy]
    type = SideAverageValue
    variable = disp_y
    boundary = top
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Eyy]
    type = ParsedPostprocessor
    pp_names = 'uy'
    function = 'uy/${Ly}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [delta_Eyy]
    type = ChangeOverTimePostprocessor
    postprocessor = Eyy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Eyy_dot]
    type = ParsedPostprocessor
    pp_names = 'delta_Eyy dt'
    function = 'delta_Eyy/dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Esyy]
    type = ADElementAverageMaterialProperty
    mat_prop = Esyy
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Epyy]
    type = ADElementAverageMaterialProperty
    mat_prop = Epyy
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [delta_Esyy]
    type = ChangeOverTimePostprocessor
    postprocessor = Esyy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [delta_Epyy]
    type = ChangeOverTimePostprocessor
    postprocessor = Epyy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Esyy_dot]
    type = ParsedPostprocessor
    function = 'delta_Esyy/dt'
    pp_names = 'delta_Esyy dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Epyy_dot]
    type = ParsedPostprocessor
    function = 'delta_Epyy/dt'
    pp_names = 'delta_Epyy dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  ignore_variables_for_autoscaling = 'c mu_var'
  line_search = none

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20
  nl_forced_its = 1

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    optimal_iterations = 6
    iteration_window = 1
    growth_factor = 2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.2
    linear_iteration_ratio = 100000
  []
  end_time = ${tf}
  dtmax = ${dtmax}

  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
    skip_times_old = '${t0}'
  []
[]

[Outputs]
  sync_times = '${t0}'
  [exodus]
    type = Exodus
    interval = 1
    file_base = '../out/4grains_conserv_periodic_bc_load${load}_a${alpha}_ai${alphai}_Mi${Mi}_M${M}_Nri${Nri}'
  []
  [csv]
    type = CSV
    file_base = '../gold/4grians_conserv_periodic_bc_load${load}_a${alpha}_ai${alphai}_Mi${Mi}_M${M}_Nri${Nri}'
  []
[]
