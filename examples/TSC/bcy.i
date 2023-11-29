Ey = 1

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'matrix_bottom'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'matrix_top'
    value = '${fparse Ey*matrix_a}'
  []
  [Periodic]
    [x]
      variable = Phi
      primary = 'matrix_left'
      secondary = 'matrix_right'
      translation = '${matrix_a} 0 0'
    []
  []
[]

[Postprocessors]
  [sigma_yy]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${Ey}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_xy]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${Ey}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
