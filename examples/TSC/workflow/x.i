[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'left fiber_left'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'right fiber_right'
    value = '${fparse E*matrix_x}'
  []
[]

[Postprocessors]
  [sigma_xx]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yx]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_zx]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
