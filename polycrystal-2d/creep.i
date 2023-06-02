lambda = 1e5
G = 8e4
alpha = -1e-5
Omega = 100
# sigma_y = 300
n = 5
A = 1e-6

c0 = 1e-3
# cref = 1e-4
cref = 1e-3
T = 800
M = 1e-8
# M = 0 # turn off bulk diffusion
mu0 = 1e3
R = 8.3145
Nr = 5e-12
# Nr = 0 # turn off bulk nucleation
Qv = 1e4

# load = 0.1
load = 200
t0 = 1e3
dt = '${fparse t0/100}'
tf = 1e4
dtmax = '${fparse tf/100}'

# GB
alphai = -1e-5
Nri = 5e-12
# Nri = 0 # turn off gb nucleation
Mi = 1e-10
# Mi = 0 # turn off diffusion
Gc = 1e20 # turn off damage
w = 1
Ei = 1e5
Gi = 8e4
Qvi = 1e4
mu0i = 1e3

Ly = 1

[GlobalParams]
  displacements = 'disp_x disp_y'
  energy_densities = 'dot(psi_m) dot(psi_c) Delta_p zeta'
  volumetric_locking_correction = false
  check_boundary_restricted = false
[]

# mesh with top and bottom half
[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 2
    dx = '0.25 0.25 0.25 0.25'
    dy = '0.25 0.25 0.25 0.25'
    ix = '20 20 20 20'
    iy = '20 20 20 20'
    subdomain_id = '0 1 2 3
                    4 5 6 7
                    8 9 10 11
                    12 13 14 15'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = cmg
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

#### gb czm setting 
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
    initial_condition = ${cref}
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
  [mass_balance_1]
    type = TimeDerivative
    variable = c
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = j
  []
  [mass_source] # turn on bulk nucleation
    type = MaterialSource
    variable = c
    prop = m
    coefficient = -1
  []
[]

[InterfaceKernels]
  [c]
    type = InterfaceContinuity
    variable = c
    neighbor_var = c
    penalty = 1e3
    boundary = interface
  []
  [gb]
    type = GBCavitationTransportTest
    variable = c
    neighbor_var = c
    cavity_flux = ji
    cavity_nucleation_rate = mi
    interface_width = ${w}
    boundary = interface
  []
  # [no_penetration_x]
  #   type = NoPenetration
  #   variable = disp_x
  #   neighbor_var = disp_x
  #   component = 0
  #   penalty = 1e7
  #   boundary = interface
  # []
  # [no_penetration_y]
  #   type = NoPenetration
  #   variable = disp_y
  #   neighbor_var = disp_y
  #   component = 1
  #   penalty = 1e7
  #   boundary = interface
  # []
[]

[Functions]
  [temporal]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${load}'
  []
  [spatial]
    type = ADParsedFunction
    # expression = 'if(x>0.5, x-0.5, 0)'
    expression = 1
  []
  [load]
    type = CompositeFunction
    functions = 'temporal spatial'
    scale_factor = 1
  []
[]

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
  [force_y]
    # type = FunctionDirichletBC
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 'top'
    function = load
  []
[]

[Materials]
  # bulk
  [chemical]
    type = ADGenericConstantMaterial
    prop_names = 'M mu0 Nr'
    prop_values = '${M} ${mu0} ${Nr}'
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
    # energy_densities = 'dot(psi_c)' # turn off stress-aided diffusion in bulk
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
  [bulk_nucleation]
    type = ADParsedMaterial
    property_name = dDelta_p/dmu
    expression = 'abs(p) * Nr * exp(- ${Qv} / ${R} / T)'
    coupled_variables = 'T'
    material_property_names = 'sigma_y ep_dot Nr p mu'
  []
  # [stiffness]
  #   type = ADGenericConstantMaterial
  #   prop_names = 'lambda G sigma_y'
  #   prop_values = '${lambda} ${G} ${sigma_y}'
  # []
  [stiffness]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${lambda} ${G}'
  []
  [yield_stress]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = sigma_y
    subdomain_to_prop_value = '0 100 1 250 2 150 3 210
                               4 300 5 50 6 220 7 100
                               8 250 9 150 10 100 11 300
                               12 150 13 300 14 250 15 100'
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
    outputs = 'exodus'
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

  ### gb
  [interface_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nri Mi Gc Ei Gi mu0i'
    prop_values = '${Nri} ${Mi} ${Gc} ${Ei} ${Gi} ${mu0i}'
    boundary = interface
  []
  [traction_separation]
    type = GBCavitationTest
    activation_energy = ${Qvi}
    penalty = 1
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
    swelling_coefficient = ${alphai}
    temperature = T
    boundary = interface
    # outputs = 'exodus'
  []
  [gb_mass_flux]
    type = GBChemicalPotentialGradient
    interface_chemical_potential = mui
    interface_mobility = Mi
    cavity_flux = ji
    concentration = c
    boundary = interface
    # outputs = 'exodus'
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
  verbose = true
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
  file_base = 'vary_sigma_y'
  csv = true
  exodus = true
  print_linear_residuals = false
[]
