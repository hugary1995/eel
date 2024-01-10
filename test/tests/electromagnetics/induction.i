# frequency
omega = 150000

# magnetic permeability
mu_workpiece = 6.3e-3
mu_air = 1.26e-6
mu_coil = 1.26e-6

# electric conducitivity
sigma_workpiece = 1e7
sigma_air = 1 # 1e-13~1e-9
sigma_coil = 6e7

# applied current density
ix = 0
iy = 0
iz = 1e4

[Mesh]
  [domain]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 0.1
    ymax = 0.4
    zmax = 0.1
    nx = 20
    ny = 80
    nz = 20
  []
  [air]
    type = SubdomainBoundingBoxGenerator
    input = domain
    block_id = 0
    block_name = air
    bottom_left = '0 0 0'
    top_right = '0.1 0.4 0.1'
  []
  [workpiece]
    type = SubdomainBoundingBoxGenerator
    input = air
    block_id = 1
    block_name = workpiece
    bottom_left = '0 0.1 0'
    top_right = '0.05 0.3 0.05'
  []
  [coil]
    type = SubdomainBoundingBoxGenerator
    input = workpiece
    block_id = 2
    block_name = coil
    bottom_left = '0.07 0.1 0'
    top_right = '0.08 0.3 0.1'
  []
[]

[Variables]
  [Are_x]
  []
  [Aim_x]
  []
  [Are_y]
  []
  [Aim_y]
  []
  [Are_z]
  []
  [Aim_z]
  []
[]

[Kernels]
  # Real part
  # [real_Hdiv_x]
  #   type = RankOneCurl
  #   variable = Are_x
  #   vector = Hre
  #   component = 0
  #   factor = 1
  # []
  # [real_Hdiv_y]
  #   type = RankOneCurl
  #   variable = Are_y
  #   vector = Hre
  #   component = 1
  #   factor = 1
  # []
  # [real_Hdiv_z]
  #   type = RankOneCurl
  #   variable = Are_z
  #   vector = Hre
  #   component = 2
  #   factor = 1
  # []
  [real_Hdiv_x]
    type = RankTwoDivergence
    variable = Are_x
    tensor = Hre
    component = 0
    factor = -1
  []
  [real_Hdiv_y]
    type = RankTwoDivergence
    variable = Are_y
    tensor = Hre
    component = 1
    factor = -1
  []
  [real_Hdiv_z]
    type = RankTwoDivergence
    variable = Are_z
    tensor = Hre
    component = 2
    factor = -1
  []
  [real_induction_x]
    type = MaterialReaction
    variable = Are_x
    coupled_variable = Aim_x
    prop = ind_coef
    coefficient = -1
  []
  [real_induction_y]
    type = MaterialReaction
    variable = Are_y
    coupled_variable = Aim_y
    prop = ind_coef
    coefficient = -1
  []
  [real_induction_z]
    type = MaterialReaction
    variable = Are_z
    coupled_variable = Aim_z
    prop = ind_coef
    coefficient = -1
  []
  [applied_current_x]
    type = MaterialSource
    variable = Are_x
    prop = ix
    coefficient = -1
    block = 'coil'
  []
  [applied_current_y]
    type = MaterialSource
    variable = Are_y
    prop = iy
    coefficient = -1
    block = 'coil'
  []
  [applied_current_z]
    type = MaterialSource
    variable = Are_z
    prop = iz
    coefficient = -1
    block = 'coil'
  []
  # Imaginery part
  # [imag_Hdiv_x]
  #   type = RankOneCurl
  #   variable = Aim_x
  #   vector = Him
  #   component = 0
  #   factor = -1
  # []
  # [imag_Hdiv_y]
  #   type = RankOneCurl
  #   variable = Aim_y
  #   vector = Him
  #   component = 1
  #   factor = -1
  # []
  # [imag_Hdiv_z]
  #   type = RankOneCurl
  #   variable = Aim_z
  #   vector = Him
  #   component = 2
  #   factor = -1
  # []
  [imag_Hdiv_x]
    type = RankTwoDivergence
    variable = Are_x
    tensor = Hre
    component = 0
    factor = -1
  []
  [imag_Hdiv_y]
    type = RankTwoDivergence
    variable = Are_y
    tensor = Hre
    component = 1
    factor = -1
  []
  [imag_Hdiv_z]
    type = RankTwoDivergence
    variable = Are_z
    tensor = Hre
    component = 2
    factor = -1
  []
  [imag_induction_x]
    type = MaterialReaction
    variable = Aim_x
    coupled_variable = Are_x
    prop = ind_coef
    coefficient = 1
  []
  [imag_induction_y]
    type = MaterialReaction
    variable = Aim_y
    coupled_variable = Are_y
    prop = ind_coef
    coefficient = 1
  []
  [imag_induction_z]
    type = MaterialReaction
    variable = Aim_z
    coupled_variable = Are_z
    prop = ind_coef
    coefficient = 1
  []
[]

[Materials]
  [workpiece]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_workpiece} ${sigma_workpiece}'
    block = 'workpiece'
  []
  [air]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_air} ${sigma_air}'
    block = 'air'
  []
  [coil]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_coil} ${sigma_coil}'
    block = 'coil'
  []
  [magnetizing_field_real]
    type = MagnetizingTensor
    magnetizing_tensor = Hre
    magnetic_vector_potential = 'Are_x Are_y Are_z'
    magnetic_permeability = mu
  []
  [magnetizing_field_imag]
    type = MagnetizingTensor
    magnetizing_tensor = Him
    magnetic_vector_potential = 'Aim_x Aim_y Aim_z'
    magnetic_permeability = mu
  []
  [induction_coef]
    type = ADParsedMaterial
    property_name = ind_coef
    expression = '${omega} * sigma'
    material_property_names = 'sigma'
  []
  [i]
    type = ADGenericFunctionMaterial
    prop_names = 'ix iy iz'
    prop_values = 't*${ix} t*${iy} t*${iz}'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu      '

  automatic_scaling = true
  reuse_preconditioner = true
  reuse_preconditioner_max_linear_its = 25

  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  nl_max_its = 50

  l_max_its = 300
  l_tol = 1e-06

  dt = 0.1
  end_time = 1
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
