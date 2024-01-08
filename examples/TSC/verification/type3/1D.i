fiber_s = 0.1 # mm, Parallel spacing between two fibers

fiber_a = 0.25 # mm, Fiber length
fiber_n = 80 # Number of elements in fiber
fiber_r = 0.02 # mm, Fiber cross-sectional radius
fiber_A = '${fparse 4*fiber_r^2}' # mm^2, fiber cross-sectional area

s = 0.25 # spacing between matrix boundaries and fiber
matrix_x = '${fparse s*2+fiber_a}' # mm
matrix_y = '${fparse s*2+fiber_a}' # mm
matrix_z = '${fparse s*2}' # mm
matrix_ex = '${fparse 1/33}'
matrix_ey = '${fparse 1/129}'
matrix_ez = '${fparse 1/33}'
matrix_nx = '${fparse ceil(matrix_x/matrix_ex)}' # Number of elements in each direction
matrix_ny = '${fparse ceil(matrix_y/matrix_ey)}' # Number of elements in each direction
matrix_nz = '${fparse ceil(matrix_z/matrix_ez)}' # Number of elements in each direction

sigma_matrix = 2e1 # S/mm, electrical conductivity https://www.frontiersin.org/articles/10.3389/fmats.2020.00219/full
sigma_fiber = 2e3 # 7.1e6 # S/mm, electrical conductivity https://pubs.acs.org/doi/10.1021/nl048687z
ECR = 1e-4

[GlobalParams]
  energy_densities = 'E'
[]

[Mesh]
  [matrix]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = ${matrix_x}
    ymax = ${matrix_y}
    zmax = ${matrix_z}
    nx = ${matrix_nx}
    ny = ${matrix_ny}
    nz = ${matrix_nz}
  []
  [matrix_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = matrix
    block_id = 0
    block_name = matrix
    bottom_left = '0 0 0'
    top_right = '${matrix_x} ${matrix_y} ${matrix_z}'
  []
  [fiber1]
    type = GeneratedMeshGenerator
    dim = 1
    xmax = ${fiber_a}
    nx = ${fiber_n}
    boundary_name_prefix = fiber1
    boundary_id_offset = 100
  []
  [fiber1_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = fiber1
    block_id = 1
    block_name = fiber
    bottom_left = '0 0 0'
    top_right = '${fiber_a} 0 0'
  []
  [fiber1_transl]
    type = TransformGenerator
    input = fiber1_subdomain
    transform = TRANSLATE
    vector_value = '${s} ${fparse s+(fiber_a-fiber_s)/2} ${s}'
  []
  [fiber2]
    type = GeneratedMeshGenerator
    dim = 1
    xmax = ${fiber_a}
    nx = ${fiber_n}
    boundary_name_prefix = fiber2
    boundary_id_offset = 200
  []
  [fiber2_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = fiber2
    block_id = 1
    block_name = fiber
    bottom_left = '0 0 0'
    top_right = '${fiber_a} 0 0'
  []
  [fiber2_transl]
    type = TransformGenerator
    input = fiber2_subdomain
    transform = TRANSLATE
    vector_value = '${s} ${fparse s+(fiber_a+fiber_s)/2} ${s}'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'matrix_subdomain fiber1_transl fiber2_transl'
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
  [charge_balance_fiber]
    type = RankOneDivergence
    variable = Phi
    vector = i
    factor = ${fiber_A}
    block = fiber
  []
[]

[Constraints]
  [resistance]
    type = EmbeddedMaterialConstraint
    variable = Phi
    primary = matrix
    secondary = fiber
    resistance = '${fparse ECR/(2*pi*fiber_r)}'
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

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 301 0.7 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  l_max_its = 300
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08

  num_steps = 1
[]

[Postprocessors]
  [Ix]
    type = NodalSum
    variable = ir
    boundary = 'right'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iy]
    type = NodalSum
    variable = ir
    boundary = 'top'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iz]
    type = NodalSum
    variable = ir
    boundary = 'front'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Ax]
    type = AreaPostprocessor
    boundary = 'right'
    execute_on = 'INITIAL'
    outputs = none
  []
  [Ay]
    type = AreaPostprocessor
    boundary = 'top'
    execute_on = 'INITIAL'
    outputs = none
  []
  [Az]
    type = AreaPostprocessor
    boundary = 'front'
    execute_on = 'INITIAL'
    outputs = none
  []
  [ix]
    type = ParsedPostprocessor
    pp_names = 'Ix Ax'
    function = 'Ix / Ax'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iy]
    type = ParsedPostprocessor
    pp_names = 'Iy Ay'
    function = 'Iy / Ay'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iz]
    type = ParsedPostprocessor
    pp_names = 'Iz Az'
    function = 'Iz / Az'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
[]

[Outputs]
  csv = true
  exodus = true
  print_linear_residuals = false
[]
