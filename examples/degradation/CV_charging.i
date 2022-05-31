[Problem]
  restart_file_base = 'T_${T0}/cycle_${cycle}_CC_charging_I_${I}_cp/LATEST'
[]

[BCs]
  [Phi]
    type = CoupledVarDirichletBC
    variable = Phi
    boundary = 'left right'
    value = Phi0
  []
[]

[Materials]
  [ramp]
    type = ADGenericFunctionMaterial
    prop_names = 'ramp'
    prop_values = '1'
  []
[]

[UserObjects]
  [kill_i]
    type = Terminator
    expression = '-I <= 1e-4'
    message = 'No current.'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  line_search = none

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 20

  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
  []
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    optimal_iterations = 7
    iteration_window = 2
    growth_factor = 1.2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.2
    linear_iteration_ratio = 1000000
  []
  dtmax = ${t0}
  start_time = 0
  end_time = 100000
[]

[Outputs]
  file_base = 'T_${T0}/cycle_${cycle}_CV_charging_I_${I}'
  csv = true
  print_linear_residuals = false
  checkpoint = true
[]
