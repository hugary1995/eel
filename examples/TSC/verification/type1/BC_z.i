Ez = 1
z = 0.5

[BCs]
  [ground]
    type = DirichletBC
    variable = Phi
    boundary = 'back'
    value = 0
  []
  [CV]
    type = DirichletBC
    variable = Phi
    boundary = 'front'
    value = '${fparse Ez*z}'
  []
[]

[Postprocessors]
  [sigma_xz]
    type = ParsedPostprocessor
    pp_names = 'ix'
    function = 'ix / ${Ez}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_yz]
    type = ParsedPostprocessor
    pp_names = 'iy'
    function = 'iy / ${Ez}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [sigma_zz]
    type = ParsedPostprocessor
    pp_names = 'iz'
    function = 'iz / ${Ez}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
