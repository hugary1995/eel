[Problem]
  restart_file_base = 'T_${T0}/cycle_${fparse cycle-1}_CC_discharging_I_${I}_cp/LATEST'
[]

[BCs]
  [left]
    type = FunctionNeumannBC
    variable = Phi
    boundary = left
    function = in
  []
  [right]
    type = DirichletBC
    variable = Phi
    boundary = right
    value = 0
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
  # [kill_a]
  #   type = Terminator
  #   expression = 'c_a_max >= ${cmax}'
  #   message = 'Concentration in anode exceeds the maximum allowable value.'
  # []
  # [kill_c]
  #   type = Terminator
  #   expression = 'c_c_min <= ${cmin}'
  #   message = 'Concentration in cathode is below the minimum allowable value.'
  # []
  [kill_V]
    type = Terminator
    expression = 'V >= 4.3'
    message = 'Voltage'
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
  nl_forced_its = 1

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
    timestep_limiting_postprocessor = target_V_dt
  []
  start_time = 0
  dtmax = ${t0}
  end_time = 1e6
[]

[Outputs]
  file_base = 'T_${T0}/cycle_${cycle}_CC_charging_I_${I}'
  csv = true
  print_linear_residuals = false
  checkpoint = true
[]
