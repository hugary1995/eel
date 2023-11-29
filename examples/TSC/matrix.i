matrix_a = 1 # mm, Matrix side length
matrix_n = 11 # Number of elements in each direction

sigma_matrix = 20 # S/mm, electrical conductivity https://www.frontiersin.org/articles/10.3389/fmats.2020.00219/full

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
    block = matrix
  []
[]

[Materials]
  [electric_constants_matrix]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_matrix}'
    block = matrix
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
    function = 'Ix / ${matrix_a}'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iy]
    type = ParsedPostprocessor
    pp_names = 'Iy'
    function = 'Iy / ${matrix_a}'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
[]

[Outputs]
  exodus = true
[]
