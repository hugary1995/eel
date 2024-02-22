sigma_matrix = 2e1 # S/mm, electrical conductivity https://www.frontiersin.org/articles/10.3389/fmats.2020.00219/full
sigma_fiber = 7.1e6 # S/mm, electrical conductivity https://pubs.acs.org/doi/10.1021/nl048687z
fiber_A = 1.2e-4 # mm^2
fiber_r = '${fparse sqrt(fiber_A/pi)}' # mm
fiber_C = '${fparse 2*pi*fiber_r}'
ECR = 1

E = 1

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
  [fiber]
    type = FileMeshGenerator
    file = '${fiber_mesh}'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'matrix fiber'
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [ir_matrix]
    block = 0
  []
  [ir_fiber]
    block = ${fibers}
  []
[]

[Kernels]
  [charge_balance_matrix]
    type = RankOneDivergence
    variable = Phi
    vector = i
    save_in = ir_matrix
    block = 0
  []
  [charge_balance_fiber]
    type = RankOneDivergence
    variable = Phi
    vector = i
    factor = ${fiber_A}
    save_in = ir_fiber
    block = ${fibers}
  []
[]

[Constraints]
  [resistance]
    type = EmbeddedMaterialConstraint
    variable = Phi
    primary = 0
    secondary = ${fibers}
    resistance = '${fparse ECR/fiber_C}'
  []
[]

[Materials]
  [electric_constants_matrix]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_matrix}'
    block = 0
  []
  [electric_constants_fiber]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_fiber}'
    block = ${fibers}
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
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 301 0.7 ext+i PMIS 4 2 0.4'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  automatic_scaling = true

  l_max_its = 300
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08

  num_steps = 1
[]

[Postprocessors]
  [Ix_matrix]
    type = NodalSum
    variable = ir_matrix
    boundary = 'right'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iy_matrix]
    type = NodalSum
    variable = ir_matrix
    boundary = 'top'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iz_matrix]
    type = NodalSum
    variable = ir_matrix
    boundary = 'front'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Ix_fiber]
    type = NodalSum
    variable = ir_fiber
    boundary = 'fiber_right'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iy_fiber]
    type = NodalSum
    variable = ir_fiber
    boundary = 'fiber_top'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [Iz_fiber]
    type = NodalSum
    variable = ir_fiber
    boundary = 'fiber_bottom'
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
    pp_names = 'Ix_matrix Ix_fiber Ax'
    function = '(Ix_matrix + Ix_fiber) / Ax'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iy]
    type = ParsedPostprocessor
    pp_names = 'Iy_matrix Iy_fiber Ay'
    function = '(Iy_matrix + Iy_fiber) / Ay'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
  [iz]
    type = ParsedPostprocessor
    pp_names = 'Iz_matrix Iz_fiber Az'
    function = '(Iz_matrix + Iz_fiber) / Az'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []
[]

[Outputs]
  csv = true
  exodus = true
  print_linear_residuals = true
[]
