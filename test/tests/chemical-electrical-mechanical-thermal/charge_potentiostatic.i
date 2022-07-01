[GlobalParams]
  energy_densities = 'psi_c psi_e psi_m'
  dissipation_densities = 'delta_c_vis delta_c_jh'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = charge_galvanostatic.e
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
  [T]
    initial_from_file_var = T
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
    value = 32
  []
  [Phi_right]
    type = DirichletBC
    variable = Phi
    boundary = 'right'
    value = 0
  []
  [c_left]
    type = DirichletBC
    variable = c
    boundary = 'left'
    value = ${c_m}
  []
[]

[UserObjects]
  [terminator]
    type = Terminator
    expression = 'soc > 0.99'
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
  dt = 10
  end_time = 10000
[]

[Outputs]
  file_base = charge_potentiostatic
  csv = true
  exodus = true
[]
