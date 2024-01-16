# frequency
f = 100
omega = '${fparse 2*pi*f}'

# magnetic permeability
mu_air = 1.26e-6
mu_pipe = '${fparse 1.004*mu_air}'
mu_PCM = '${fparse 1*mu_air}'
mu_container = '${fparse 1.004*mu_air}'
mu_insulation = '${fparse 1*mu_air}'
mu_coil = '${fparse 1*mu_air}'

# electrical conducitivity
sigma_air = 1e-9 # 1e-13~1e-9
sigma_pipe = 750750.75 # S/m
sigma_PCM = 23810 # S/m (from Bob's measurement in radial direction)
sigma_container = 750750.75 # S/m
sigma_insulation = 1e3 # S/m
sigma_coil = 6e7 # S/m

# applied current density
V = 208 # Volt
R_coil = 0.4108 # m
n_coil = 10
ix = '${fparse sigma_coil*V/2/pi/R_coil/n_coil}'
iy = 0

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/domain.msh'
  []
  coord_type = RZ
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
[]

[AuxVariables]
  [T]
    block = 'pipe PCM container insulation'
  []
  [q]
    family = MONOMIAL
    order = CONSTANT
    [AuxKernel]
      type = ADMaterialRealAux
      property = q
      execute_on = 'TIMESTEP_END'
    []
    block = 'pipe PCM container insulation'
  []
  [ie]
    family = MONOMIAL
    order = CONSTANT
    [AuxKernel]
      type = ADMaterialRealAux
      property = ie
      execute_on = 'TIMESTEP_END'
    []
  []
[]

[Kernels]
  # Real part
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
  [applied_current_x]
    type = MaterialSource
    variable = Are_x
    prop = ${ix}
    coefficient = -1
    block = 'coil'
  []
  [applied_current_y]
    type = MaterialSource
    variable = Are_y
    prop = ${iy}
    coefficient = -1
    block = 'coil'
  []

  # Imaginary part
  [imag_Hdiv_x]
    type = RankTwoDivergence
    variable = Aim_x
    tensor = Him
    component = 0
    factor = -1
  []
  [imag_Hdiv_y]
    type = RankTwoDivergence
    variable = Aim_y
    tensor = Him
    component = 1
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
[]

[Materials]
  [pipe]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_pipe} ${sigma_pipe}'
    block = 'pipe'
  []
  [PCM]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_PCM} ${sigma_PCM}'
    block = 'PCM'
  []
  [container]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_container} ${sigma_container}'
    block = 'container'
  []
  [insulation]
    type = ADGenericConstantMaterial
    prop_names = 'mu sigma'
    prop_values = '${mu_insulation} ${sigma_insulation}'
    block = 'insulation'
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
    magnetic_vector_potential = 'Are_x Are_y'
    magnetic_permeability = mu
  []
  [magnetizing_field_imag]
    type = MagnetizingTensor
    magnetizing_tensor = Him
    magnetic_vector_potential = 'Aim_x Aim_y'
    magnetic_permeability = mu
  []
  [induction_coef]
    type = ADParsedMaterial
    property_name = ind_coef
    expression = 'omega * sigma'
    material_property_names = 'omega sigma'
  []
  [frequency]
    type = ADGenericFunctionMaterial
    prop_names = 'omega'
    prop_values = '${omega}'
  []
  [current]
    type = EddyCurrent
    current_density = ie
    frequency = omega
    electrical_conductivity = sigma
    magnetic_vector_potential_real = 'Are_x Are_y'
    magnetic_vector_potential_imaginary = 'Aim_x Aim_y'
  []
  [heat]
    type = InductionHeating
    heat_source = q
    frequency = omega
    electrical_conductivity = sigma
    magnetic_vector_potential_real = 'Are_x Are_y'
    magnetic_vector_potential_imaginary = 'Aim_x Aim_y'
    block = 'pipe PCM container insulation'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'

  automatic_scaling = true
  reuse_preconditioner = true
  reuse_preconditioner_max_linear_its = 25

  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  nl_max_its = 50

  l_max_its = 300
  l_tol = 1e-06

  dt = 1e12
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
