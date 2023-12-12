matrix_a = 1 # mm
matrix_t = 0.02 # mm
matrix_n = 100
matrix_nt = 4

fiber_a = 0.8 # mm

sigma_matrix = 20 # S/mm, electrical conductivity
sigma_fiber = 2000 # S/mm, electrical conductivity
ECR = 1e-3 # Ohm mm^2, contact resistance

[GlobalParams]
  energy_densities = 'E'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = '${fparse -0.5*matrix_a}'
    xmax = '${fparse 0.5*matrix_a}'
    ymin = '${fparse -0.5*matrix_a}'
    ymax = '${fparse 0.5*matrix_a}'
    zmin = '${fparse -0.5*matrix_t}'
    zmax = '${fparse 0.5*matrix_t}'
    nx = ${matrix_n}
    ny = ${matrix_n}
    nz = ${matrix_nt}
    boundary_name_prefix = matrix
  []
  [matrix]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    block_name = matrix
    bottom_left = '${fparse -0.5*matrix_a} ${fparse -0.5*matrix_a} ${fparse -0.5*matrix_t}'
    top_right = '${fparse 0.5*matrix_a} ${fparse 0.5*matrix_a} ${fparse 0.5*matrix_t}'
  []
  [fiber]
    type = SubdomainBoundingBoxGenerator
    input = matrix
    block_id = 1
    block_name = fiber
    bottom_left = '${fparse -0.5*matrix_t} ${fparse -0.5*fiber_a} ${fparse -0.5*matrix_t}'
    top_right = '${fparse 0.5*matrix_t} ${fparse 0.5*fiber_a} ${fparse 0.5*matrix_t}'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = fiber
    split_interface = true
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [ir]
  []
[]

[Kernels]
  [charge_balance_matrix]
    type = RankOneDivergence
    variable = Phi
    vector = i
    save_in = ir
  []
[]

[InterfaceKernels]
  [resistance]
    type = InterfaceContinuity
    variable = Phi
    neighbor_var = Phi
    penalty = '${fparse 1/ECR}'
    boundary = 'matrix_fiber'
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
    prop_values = '${sigma_fiber}'
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
