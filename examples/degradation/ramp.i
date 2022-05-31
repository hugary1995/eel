[ICs]
  [c_min]
    type = ConstantIC
    variable = c
    value = ${cmin}
    block = 'anode'
  []
  [c_mid]
    type = ConstantIC
    variable = c
    value = '${fparse (cmax+cmin)/2}'
    block = 'elyte'
  []
  [c_max]
    type = ConstantIC
    variable = c
    value = ${cmax}
    block = 'cathode'
  []
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
    prop_values = 'if(t<${t0},t/${t0},1)'
  []
[]

[UserObjects]
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
  dtmax = ${t0}
  end_time = 1000000
  abort_on_solve_fail = true
[]

[Outputs]
  file_base = 'T_${T0}/cycle_1_CC_charging_I_${I}'
  csv = true
  print_linear_residuals = false
  checkpoint = true
  exodus = true
[]
