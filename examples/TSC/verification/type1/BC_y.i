Ey = 1
y = 0.5

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'bottom'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'top'
    value = '${fparse Ey*y}'
  []
[]

[Postprocessors]
  [sigma_xy]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${Ey}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yy]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${Ey}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_zy]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${Ey}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
