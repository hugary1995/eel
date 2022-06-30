[GlobalParams]
  energy_densities = 'psi_c psi_e psi_m'
  dissipation_densities = 'delta_c_vis delta_c_jh'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = charge_potentiostatic.e
    use_for_exodus_restart = true
  []
[]

[Variables]
  [c]
    initial_from_file_var = c
  []
  [Phi]
    initial_from_file_var = Phi
  []
  [disp_x]
    initial_from_file_var = disp_x
  []
  [disp_y]
    initial_from_file_var = disp_y
  []
[]

[BCs]
  [Phi_left]
    type = DirichletBC
    variable = Phi
    boundary = 'left'
    value = 0.032
  []
  [Phi_right]
    type = DirichletBC
    variable = Phi
    boundary = 'right'
    value = 0
  []
  [c_right]
    type = DirichletBC
    variable = c
    boundary = 'right'
    value = ${c_m}
  []
[]

[Postprocessors]
  [c_surface]
    type = PointValue
    variable = c
    point = '0 0 0'
    outputs = none
  []
[]

[UserObjects]
  [terminator]
    type = Terminator
    expression = 'c_surface <= 0'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-10
  dt = 1
  end_time = 1000
[]

[Outputs]
  file_base = discharge_galvanostatic
  csv = true
  exodus = true
[]
