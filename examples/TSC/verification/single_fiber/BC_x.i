Ex = 1

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'matrix_left'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'matrix_right'
    value = '${fparse Ex*matrix_a}'
  []
[]

[Postprocessors]
  [sigma_xx]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${Ex}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yx]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${Ex}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
