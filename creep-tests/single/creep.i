# bulk
lambda = 1e5
G = 8e4
alpha = -0.1
Omega = 100
sigma_y = 1e8
n = 5
A = 0 # turn off plasticity
Nr = 0 # turn off nucleation in bulk

c0 = 1
c_ref = 1
T = 800
# M = 1e-11
M = 1e-16
mu0 = 1e3
R = 8.3145

# GB
alphai = -0.1
Nri = 1e-10
# Mi = 1e-16
Mi = 1e-6
Gc = 1e40
w = 1
Ei = 1e5
Gi = 8e4
Qvi = 1e4
mu0i = 1e3

#
load = 50
t0 = 10
tf = 10000
dt = 10
dtmax = 10

[GlobalParams]
  displacements = 'disp_x disp_y'
  energy_densities = 'dot(psi_m) dot(psi_c) Delta_p zeta'
  volumetric_locking_correction = true
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 50
    xmax = 1
    ymax = 1
  []
  [outer]
    type = ParsedSubdomainMeshGenerator
    input = gmg
    combinatorial_geometry = 'x>=0.9 | y>=0.9'
    block_id = 1
    block_name = outer
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = outer
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
  [spatial]
    type = PiecewiseLinear
    x = '0 1'
    y = '-${load} ${load}'
    axis = y
  []
  [load_top]
    type = CompositeFunction
    functions = 'temporal'
    scale_factor = 1
  []
  [load_right]
    type = CompositeFunction
    functions = 'temporal spatial'
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
  [force_x]
    type = FunctionNeumannBC
    variable = disp_x
    # variable = disp_y
    boundary = 'right'
    function = load_right
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
[]

[Postprocessors]
  # cavity
  [cavity_density]
    type = ElementAverageValue
    variable = c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [cavity_density_bulk]
    type = ElementAverageValue
    variable = c
    block = '0'
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
  [PA_c]
    type = NodalVariableValue
    nodeid = 2297
    variable = c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PB_c]
    type = NodalVariableValue
    nodeid = 91
    variable = c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # strain rate
  [dt]
    type = TimestepSize
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [PA_ux]
    type = NodalVariableValue
    nodeid = 2297
    variable = disp_x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PA_uy]
    type = NodalVariableValue
    nodeid = 2297
    variable = disp_y
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PB_ux]
    type = NodalVariableValue
    nodeid = 91
    variable = disp_x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PB_uy]
    type = NodalVariableValue
    nodeid = 91
    variable = disp_y
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dPA_ux]
    type = ChangeOverTimePostprocessor
    postprocessor = PA_ux
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [dPA_uy]
    type = ChangeOverTimePostprocessor
    postprocessor = PA_uy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [dPB_ux]
    type = ChangeOverTimePostprocessor
    postprocessor = PB_ux
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [dPB_uy]
    type = ChangeOverTimePostprocessor
    postprocessor = PB_uy
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [PA_ux_dot]
    type = ParsedPostprocessor
    pp_names = 'dPA_ux dt'
    function = 'dPA_ux/dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PA_uy_dot]
    type = ParsedPostprocessor
    pp_names = 'dPA_uy dt'
    function = 'dPA_uy/dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PB_ux_dot]
    type = ParsedPostprocessor
    pp_names = 'dPB_ux dt'
    function = 'dPB_ux/dt'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [PB_uy_dot]
    type = ParsedPostprocessor
    pp_names = 'dPB_uy dt'
    function = 'dPB_uy/dt'
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
    interval = 10
    file_base = '../out/single_traction_load${load}_Mi${Mi}_M${M}_Nri${Nri}'
  []
  [csv]
    type = CSV
    file_base = '../gold/single_traction_load${load}_Mi${Mi}_M${M}_Nri${Nri}'
  []
[]
