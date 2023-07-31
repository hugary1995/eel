# bulk
lambda = 1e5
G = 8e4
alpha = -1e-3
Omega = 100
sigma_y = 300
n = 5
# A = 1e-6
A = 0 # turn off visco-plasticity

c0 = 1e-3
c0_max = 1.01e-3
c0_min = 0.99e-3
T = 800
# M = 1e-8
M = 1e-11
mu0 = 1e3
R = 8.3145
# Nr = 1e-11
Nr = 0.0
Qv = 5e4

## GB
alphai = -1e-3
# Nri = 5e-12
Nri = 0.0
Qvi = 1e4
# Mi = 1e-8
Mi = 1e-11
Gc = 1e30
# w = 1e-3
w = 1
Ei = 1e5
Gi = 8e4
mu0i = 1e3

# load
load = 10
# t0 = '${fparse load*60}'
# dt = '${fparse t0/100}'
# tf = 1e9
# dtmax = '${fparse tf/1000}'
t0 = 10
tf = 4000
dt = 1
dtmax = 10

Ly = 2

[GlobalParams]
  displacements = 'disp_x disp_y'
  energy_densities = 'dot(psi_m) dot(psi_c) Delta_p zeta'
  volumetric_locking_correction = true # volumetric locking will averge stree over the element, so no mass flux
[]

[Mesh]
  # [gmg]
  #   type = GeneratedMeshGenerator
  #   dim = 3
  #   xmax = 1
  #   ymax = 2
  #   zmax = 1
  #   nx = 1
  #   ny = 2
  #   nz = 1
  # []
  # [bottom_half]
  #   type = SubdomainBoundingBoxGenerator
  #   input = gmg
  #   block_id = 0
  #   bottom_left = '0 0 0'
  #   top_right = '1 1 1'
  # []
  # [top_half]
  #   type = SubdomainBoundingBoxGenerator
  #   input = bottom_half
  #   block_id = 1
  #   bottom_left = '0 1 0'
  #   top_right = '1 2 1'
  # []
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 10
    ymax = 2
    nx = 10
    ny = 2
  []
  [bottom_half]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '10 1 0'
  []
  [top_half]
    type = SubdomainBoundingBoxGenerator
    input = bottom_half
    block_id = 1
    bottom_left = '0 1 0'
    top_right = '10 2 0'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = top_half
  []
  use_displaced_mesh = false
[]

# for gb interface
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
  # [disp_z]
  # []
  [mu_var]
  []
  [c]
    # initial_condition = ${c0}
    [InitialCondition]
      type = FunctionIC
      function = 'if(x<=5, ${c0_max}, ${c0_min})'
    []
  []
[]

[AuxVariables]
  [c_ref]
    initial_condition = ${c0}
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
  # [momentum_balance_z]
  #   type = RankTwoDivergence
  #   variable = disp_z
  #   component = 2
  #   tensor = cauchy
  #   factor = -1
  # []
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
    penalty = 1e4
  []
[]

[Functions]
  [load]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${load}'
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
  # [fix_z]
  #   type = DirichletBC
  #   variable = disp_z
  #   boundary = 'back'
  #   value = 0
  # []
  [force_y]
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 'top'
    function = load
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
  # [ev_z]
  #   type = EqualValueBoundaryConstraint
  #   variable = disp_z
  #   secondary = front
  #   penalty = 1e8
  # []
[]

[Materials]
  # creep-diffision (bulk)
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nr'
    prop_values = '${Nr}'
  []
  [bulk_nucleation]
    type = ADParsedMaterial
    property_name = dDelta_p/dmu
    expression = 'if(p>0,1,0) * p * Nr * exp(- ${Qv} / ${R} / T)'
    # expression = 'abs(p) * Nr * exp(- ${Qv} / ${R} / T)'
    coupled_variables = 'T'
    material_property_names = 'sigma_y ep_dot Nr p mu'
  []

  #
  [chemical]
    type = ADGenericConstantMaterial
    prop_names = 'M mu0'
    prop_values = '${M} ${mu0}'
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
    concentration = c
    outputs = exodus
  []
  [mass_source]
    type = MassSource
    mass_source = m
    chemical_potential = mu
    outputs = exodus
  []
  [stiffness]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G sigma_y'
    prop_values = '${lambda} ${G} ${sigma_y}'
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
    output_properties = 'ep ddot(psi_m)/ddot(c)'
    outputs = 'exodus'
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
    outputs = exodus
  []
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

  # gb
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
    # output_properties = 'mui'
    # outputs = exodus
  []
[]

[Postprocessors]
  [cmin]
    type = NodalExtremeValue
    variable = c
    value_type = min
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
  [dt]
    type = TimestepSize
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
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
  [mu_avg]
    type = ADElementAverageMaterialProperty
    mat_prop = mu
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mu_var_avg]
    type = ElementAverageValue
    variable = mu_var
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  ignore_variables_for_autoscaling = 'c'
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
  file_base = 'out/nuc-off-plastic-off/M${M}'
  csv = true
  exodus = true
[]
