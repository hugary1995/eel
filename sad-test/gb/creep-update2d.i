lambda = 1e5
G = 8e4
# alpha = 1
alpha = 100
Omega = 100
sigma_y = 300
n = 5
A = 1e-6

c0 = 1e-6
T = 800
M = 1e-8
mu0 = 1e3
R = 8.3145

load = 1
t0 = '${fparse load*60}'
dt = '${fparse t0/100}'
tf = 1e9
dtmax = '${fparse tf/1000}'

# GB
# Nri = 5e-12
Nri = 0
# Mi = 1e-10
Mi = 1e-8
# Gc = 0.5
Gc = 1e20
w = 1e-3
Ei = 1e5
Gi = 8e4
Qvi = 1e4
mu0i = 1e3

Ly = 1

[GlobalParams]
  displacements = 'disp_x disp_y'
  energy_densities = 'dot(psi_m) dot(psi_c) Delta_p zeta'
  volumetric_locking_correction = false
[]

# mesh with top and bottom half
[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
  []
  [bottom_half]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 0.5 0'
  []
  [top_half]
    type = SubdomainBoundingBoxGenerator
    input = bottom_half
    block_id = 1
    bottom_left = '0 0.5 0'
    top_right = '1 1 0'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = top_half
    add_interface_on_two_sides = true
  []
  use_displaced_mesh = false
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [c]
    initial_condition = ${c0}
  []
[]

#### for gb interface
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

[AuxVariables]
  [c_ref]
    initial_condition = ${c0}
  []
  # [c]
  #   initial_condition = ${c0}
  # []
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
  [mass_balance_1]
    type = TimeDerivative
    variable = c
  []
  # [mass_balance_2]
  #   type = RankOneDivergence
  #   variable = c
  #   vector = j
  # []
  # [mass_source]
  #   type = MaterialSource
  #   variable = c
  #   prop = m
  #   coefficient = -1
  # []
[]

[InterfaceKernels]
  [gb]
    type = GBCavitationTransportTest
    variable = c
    neighbor_var = c
    cavity_flux = ji
    cavity_nucleation_rate = mi
    boundary = interface
  []
[]

[Functions]
  [temporal]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${load}'
  []
  # [spatial]
  #   type = PiecewiseLinear
  #   axis = x
  #   x = '0 0.5 1'
  #   y = '0 1 1'
  # []
  [spatial]
    type = ADParsedFunction
    expression = 'if(x<0.5, 0, 1)'
  []
  [load]
    type = CompositeFunction
    functions = 'temporal spatial'
    scale_factor = 1
  []
  # [load]
  #   type = PiecewiseLinear
  #   x = '0 ${t0}'
  #   y = '0 -1'
  # []
[]

# [BCs]
#   [fix_x]
#     type = DirichletBC
#     variable = disp_x
#     boundary = 'bottom'
#     value = 0
#   []
#   [fix_y]
#     type = DirichletBC
#     variable = disp_y
#     boundary = 'bottom'
#     value = 0
#   []
#   [fix_z]
#     type = DirichletBC
#     variable = disp_z
#     boundary = 'bottom'
#     value = 0
#   []
#   [force_y]
#     type = FunctionNeumannBC
#     variable = disp_y
#     boundary = 'top'
#     function = load
#   []
# []

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom'
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
    # type = FunctionDirichletBC
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 'top'
    function = load
  []
[]

# [Constraints]
#   [ev_x]
#     type = EqualValueBoundaryConstraint
#     variable = disp_x
#     secondary = right
#     penalty = 1e8
#   []
#   [ev_y]
#     type = EqualValueBoundaryConstraint
#     variable = disp_y
#     secondary = top
#     penalty = 1e8
#   []
#   [ev_z]
#     type = EqualValueBoundaryConstraint
#     variable = disp_z
#     secondary = front
#     penalty = 1e8
#   []
# []

[Materials]
  # bulk
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
    type = ChemicalPotential
    chemical_potential = mu
    energy_densities = 'dot(psi_c)' # turn off stress-aided diffusion in bulk
    concentration = c
    outputs = exodus
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
    prop_names = 'Nri Mi Gc Ei Gi mu0i'
    prop_values = '${Nri} ${Mi} ${Gc} ${Ei} ${Gi} ${mu0i}'
    boundary = interface
  []
  [traction_separation]
    type = GBCavitationTest
    activation_energy = ${Qvi}
    penalty = 1e3
    # cavity_flux = ji
    cavity_nucleation_rate = mi
    concentration = c
    reference_concentration = c_ref
    reference_chemical_potential = mu0i
    interface_chemical_potential = mui
    critical_energy_release_rate = Gc
    damage = d
    ideal_gas_constant = ${R}
    interface_width = ${w}
    # mobility = M
    molar_volume = ${Omega}
    reference_nucleation_rate = Nri
    normal_stiffness = Ei
    tangential_stiffness = Gi
    swelling_coefficient = alpha
    temperature = T
    boundary = interface
    outputs = 'exodus'
  []
  # [traction_separation]
  #   type = GBCavitation
  #   activation_energy = ${Qvi}
  #   cavity_flux = ji
  #   cavity_nucleation_rate = mi
  #   concentration = c
  #   reference_concentration = c_ref
  #   reference_chemical_potential = mu0i
  #   # chemical_potential = mui
  #   critical_energy_release_rate = Gc
  #   damage = d
  #   ideal_gas_constant = ${R}
  #   interface_width = ${w}
  #   mobility = Mi
  #   molar_volume = ${Omega}
  #   reference_nucleation_rate = Nri
  #   normal_stiffness = Ei
  #   tangential_stiffness = Gi
  #   swelling_coefficient = alpha
  #   temperature = T
  #   boundary = interface
  #   outputs = 'exodus'
  # []
  [gb_mass_flux]
    type = GBChemicalPotentialGradient
    interface_chemical_potential = mui
    interface_mobility = Mi
    cavity_flux = ji
    concentration = c
    boundary = interface
    outputs = 'exodus'
  []
[]

[Postprocessors]
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
  num_steps = 10

  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
    skip_times_old = '${t0}'
  []
[]

[Outputs]
  sync_times = '${t0}'
  file_base = 'out/2d_T_${T}_load_${load}'
  csv = true
  exodus = true
[]
