matrix_a = 1 # mm, Matrix side length
matrix_n = 88 # Number of elements in each direction
matrix_t = 0.02 # mm, Matrix thickness

sigma_matrix = 20 # S/mm, electrical conductivity https://www.frontiersin.org/articles/10.3389/fmats.2020.00219/full

fiber_a = 0.8 # mm, Fiber length
fiber_n = 80 # Number of elements in fiber
fiber_A = '${fparse matrix_t*matrix_t}' # mm^2, fiber cross-sectional area

sigma_fiber = 2000 # 7.1e6 # S/mm, electrical conductivity https://pubs.acs.org/doi/10.1021/nl048687z

ECR = 1e-3 # Ohm mm^2, contact resistance
ECRc = 1e-2 # Ohm mm^2, contact resistance
k = 1
H = '${fparse 1/(1+(ECR/ECRc)^(-2*k))}'

sigma_fiber_eff = '${fparse sigma_fiber*(1-H)}'
ECR_eff = '${fparse if(ECR*(1-H)<1e-8,1e-8,ECR*(1-H))}'

[GlobalParams]
  energy_densities = 'E'
[]

[Mesh]
  [matrix]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = '${fparse -0.5*matrix_a}'
    xmax = '${fparse 0.5*matrix_a}'
    ymin = '${fparse -0.5*matrix_a}'
    ymax = '${fparse 0.5*matrix_a}'
    nx = ${matrix_n}
    ny = ${matrix_n}
    boundary_name_prefix = matrix
  []
  [matrix_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = matrix
    block_id = 0
    block_name = matrix
    bottom_left = '${fparse -0.5*matrix_a} ${fparse -0.5*matrix_a} 0'
    top_right = '${fparse 0.5*matrix_a} ${fparse 0.5*matrix_a} 0'
  []
  [fiber]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = '${fparse -0.5*fiber_a}'
    xmax = '${fparse 0.5*fiber_a}'
    nx = ${fiber_n}
    boundary_name_prefix = fiber
    boundary_id_offset = 4
  []
  [fiber_rotate]
    type = TransformGenerator
    input = fiber
    transform = ROTATE
    vector_value = '90 0 0'
  []
  [fiber_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = fiber_rotate
    block_id = 1
    block_name = fiber
    bottom_left = '${fparse -0.5*fiber_a} ${fparse -0.5*fiber_a} 0'
    top_right = '${fparse 0.5*fiber_a} ${fparse 0.5*fiber_a} 0'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'matrix_subdomain fiber_subdomain'
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [ir]
  []
  # [sigma]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   [AuxKernel]
  #     type = ADMaterialRealAux
  #     property = sigma
  #     execute_on = 'INITIAL TIMESTEP_END'
  #   []
  # []
[]

[Kernels]
  [charge_balance_matrix]
    type = RankOneDivergence
    variable = Phi
    vector = i
    factor = ${matrix_t}
    save_in = ir
    block = matrix
  []
  [charge_balance_fiber]
    type = RankOneDivergence
    variable = Phi
    vector = i
    factor = ${fiber_A}
    save_in = ir
    block = fiber
  []
[]

[Constraints]
  [resistance]
    type = EmbeddedMaterialConstraint
    variable = Phi
    primary = matrix
    secondary = fiber
    resistance = '${fparse ECR_eff/2/matrix_t}'
  []
[]

[Materials]
  [electric_constants_matrix]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_matrix}'
    block = matrix
  []
  [electric_constants_fiber]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_fiber_eff}'
    block = fiber
  []
  [charge_transport_matrix]
    type = BulkChargeTransport
    electrical_energy_density = E
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [current_matrix]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08

  num_steps = 1
[]

[Postprocessors]
  [sigma_fiber_effective]
    type = ConstantPostprocessor
    value = '${sigma_fiber_eff}'
    execute_on = 'INITIAL'
  []
  [ECR_effective]
    type = ConstantPostprocessor
    value = '${ECR_eff}'
    execute_on = 'INITIAL'
  []
  [Ix]
    type = NodalSum
    variable = ir
    boundary = 'matrix_right'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iy]
    type = NodalSum
    variable = ir
    boundary = 'matrix_top'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [ix]
    type = ParsedPostprocessor
    pp_names = 'Ix'
    function = 'Ix / ${matrix_a} / ${matrix_t}'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iy]
    type = ParsedPostprocessor
    pp_names = 'Iy'
    function = 'Iy / ${matrix_a} / ${matrix_t}'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
