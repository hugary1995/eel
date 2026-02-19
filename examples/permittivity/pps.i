[Postprocessors]
  [D_eff_real_x]
    type = ADElementAverageMaterialProperty
    mat_prop = D_real_x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [D_eff_real_y]
    type = ADElementAverageMaterialProperty
    mat_prop = D_real_y
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [D_eff_imag_x]
    type = ADElementAverageMaterialProperty
    mat_prop = D_imag_x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [D_eff_imag_y]
    type = ADElementAverageMaterialProperty
    mat_prop = D_imag_y
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
