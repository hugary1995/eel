Ex = 1
x = 1

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'left'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'right'
    value = '${fparse Ex*x}'
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
  [sigma_zx]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${Ex}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
