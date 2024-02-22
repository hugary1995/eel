[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'back fiber_back'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'front fiber_front'
    value = '${fparse E*matrix_z}'
  []
[]

[Postprocessors]
  [sigma_xz]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yz]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_zz]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${E}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
