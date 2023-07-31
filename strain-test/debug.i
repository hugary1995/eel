load = 50
t0 = 3000
dt = '${fparse t0/100}'

lambda = 1e5
G = 8e4
alpha = -1.0
sigma_y = 300
n = 5
A = 0
mu0 = 1e3

alphai = -1.0
Nri = 0
Mi = 1e-8
Gc = 1e20
w = 1
Ei = 1e5
Gi = 8e4
Qvi = 1e4
mu0i = 1e3
R = 8.3145
Omega = 100

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
  []
  [bottom_half]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 0.5 1'
  []
  [top_half]
    type = SubdomainBoundingBoxGenerator
    input = bottom_half
    block_id = 1
    bottom_left = '0 0.5 0'
    top_right = '1 1 1'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = top_half
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
[]

[AuxVariables]
  [c]
    initial_condition = 1e-6
  []
  [c_ref]
    initial_condition = 1e-6
  []
  [T]
    initial_condition = 800
  []
  [eyy]
    order = CONSTANT
    family = MONOMIAL
  []
  [gb_eyy]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
  []
[]

[AuxKernels]
  # [strain_yy]
  #   type = ADRankTwoAux
  #   variable = eyy
  #   rank_two_tensor = 'total_strain'
  #   index_i = 1
  #   index_j = 1
  #   block = '0 1'
  # []
  [gb_strain_yy]
    type = ADRankTwoAux
    variable = gb_eyy
    rank_two_tensor = 'E'
    index_i = 1
    index_j = 1
    boundary = interface
  []
[]

# [InterfaceKernels]
#   [continuity_x]
#     type = InterfaceContinuity
#     variable = disp_x
#     neighbor_var = disp_x
#     boundary = interface
#     penalty = 1e6
#   []
#   [continuity_y]
#     type = InterfaceContinuity
#     variable = disp_y
#     neighbor_var = disp_y
#     boundary = interface
#     penalty = 1e6
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
  [force_y]
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 'top'
    function = load
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
    axis = x
    x = '0 0.5 1'
    y = '0 0 1'
  []
  [load]
    type = CompositeFunction
    functions = 'temporal spatial'
    scale_factor = -1
  []
[]

[Materials]
  [stress_trace]
    type = ADRankTwoInvariant
    rank_two_tensor = stress
    invariant = FirstInvariant
    property_name = trace
    outputs = exodus
  []
  [mu_parsed]
    type = ADParsedMaterial
    expression = '-alpha*${Omega}*trace + mu0 + ${R}*T*log(c/c_ref)'
    material_property_names = 'alpha trace mu0'
    coupled_variables = 'c c_ref T'
    outputs = exodus
    property_name = mu_parsed
  []
  [chemical]
    type = ADGenericConstantMaterial
    prop_names = 'mu0'
    prop_values = '${mu0}'
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
  [elasticity_tensor]
    type = ADComputeElasticityTensor
    C_ijkl = '1e5 0.2'
    fill_method = symmetric_isotropic_E_nu
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
  [small_strain]
    type = Strain
    strain = E
    output_properties = 'E'
    outputs = exodus
  []
  [mechanical_strain]
    type = MechanicalStrain
    swelling_strain = Es
    strain = E
    mechanical_strain = Em
    eigen_strain = Eg
  []
  [swelling]
    type = SwellingStrain
    concentration = c
    reference_concentration = c_ref
    molar_volume = ${Omega}
    swelling_coefficient = alpha
    swelling_strain = Es
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
    output_properties = 'ep ddot(psi_m)/ddot(c) dot(psi_m)'
    outputs = 'exodus'
  []
  # [stress]
  #   type = ADComputeLinearElasticStress
  #   output_properties = 'stress'
  # []
  [stress]
    type = SDStress
    cauchy_stress = stress
    strain_rate = 'dot(E)'
    outputs = exodus
  []
  # [czm]
  #   type = ADPureElasticTractionSeparation
  #   normal_stiffness = 1e5
  #   tangent_stiffness = 1e3
  #   boundary = interface
  # []
  [interface_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nri Mi Gc Ei Gi mu0i alphai'
    prop_values = '${Nri} ${Mi} ${Gc} ${Ei} ${Gi} ${mu0i} ${alphai}'
    boundary = interface
  []
  [gb]
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
    stress = stress
    outputs = 'exodus'
    output_properties = 'mui'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  start_time = 0.0
  num_steps = 10
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
[]

[Outputs]
  exodus = true
[]
