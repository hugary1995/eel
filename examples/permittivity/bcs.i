E0 = 0
E1 = 1

[BCs]
  [phi_real]
    type = FunctionDirichletBC
    variable = phi_real
    function = '${E0}*x + ${E1}*y'
    boundary = 'left right top bottom'
  []
  [phi_imag]
    type = DirichletBC
    variable = phi_imag
    value = 0
    boundary = 'left right top bottom'
  []
[]
