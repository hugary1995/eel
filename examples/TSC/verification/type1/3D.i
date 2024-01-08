sigma_matrix = 2e1 # S/mm, electrical conductivity
sigma_fiber = 2e3 # S/mm, electrical conductivity

[GlobalParams]
  energy_densities = 'E'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/matrix_fiber.msh'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = fmg
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

[Functions]
  [ECR]
    type = PiecewiseLinear
    data_file = 'ECR_3D.csv'
    x_title = 'x'
    y_title = 'y'
    format = columns
  []
  [penalty]
    type = ParsedFunction
    symbol_names = 'ECR'
    symbol_values = 'ECR'
    expression = '1/ECR'
  []
[]

[InterfaceKernels]
  [resistance]
    type = InterfaceContinuity
    variable = Phi
    neighbor_var = Phi
    penalty = 'penalty'
    boundary = 'fiber_matrix'
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

  dt = 1
  end_time = 20

  l_max_its = 300
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08

  [Quadrature]
    order = FIRST
  []
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
