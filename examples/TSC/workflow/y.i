[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'bottom fiber_bottom'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'top fiber_top'
    value = '${fparse E*matrix_y}'
  []
[]

[Postprocessors]
  [sigma_xy]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yy]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_zy]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
