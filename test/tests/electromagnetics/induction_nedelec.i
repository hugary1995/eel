# frequency
f = 100
omega = '${fparse 2*pi*f}'

# magnetic permeability
mu_air = 1.26e-6
mu_workpiece = '${fparse 5000*mu_air}'
mu_coil = '${fparse 1*mu_air}'

# electric conducitivity
sigma_workpiece = 1e7
sigma_air = 1e-6 # 1e-13~1e-9
sigma_coil = 6e7

# applied current density
ix = 1e4
iy = 0

[Mesh]
  [domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 0.1
    ymax = 0.4
    nx = 20
    ny = 80
  []
  [air]
    type = SubdomainBoundingBoxGenerator
    input = domain
    block_id = 0
    block_name = air
    bottom_left = '0 0 0'
    top_right = '0.1 0.4 0'
  []
  [workpiece]
    type = SubdomainBoundingBoxGenerator
    input = air
    block_id = 1
    block_name = workpiece
    bottom_left = '0 0.05 0'
    top_right = '0.05 0.35 0'
  []
  [coil]
    type = SubdomainBoundingBoxGenerator
    input = workpiece
    block_id = 2
    block_name = coil
    bottom_left = '0.07 0.195 0'
    top_right = '0.08 0.205 0'
  []
  second_order = true
[]

[Variables]
  [Hre]
    family = NEDELEC_ONE
  []
  [Him]
    family = NEDELEC_ONE
  []
[]

[Kernels]
  [curlCurl_real]
    type = CurlCurlField
    variable = Ere
  []
  [coeff_real]
    type = VectorFunctionReaction
    variable = Ere
    function = waveNumberSquared
    sign = negative
  []
  [source_real]
    type = VectorCurrentSource
    variable = E_real
    component = real
    source_real = curr_real
    source_imag = curr_imag
    function_coefficient = omegaMu
    block = source
  []
  [curlCurl_imag]
    type = CurlCurlField
    variable = E_imag
  []
  [coeff_imag]
    type = VectorFunctionReaction
    variable = E_imag
    function = waveNumberSquared
    sign = negative
  []
  [source_imaginary]
    type = VectorCurrentSource
    variable = E_imag
    component = imaginary
    source_real = curr_real
    source_imag = curr_imag
    function_coefficient = omegaMu
    block = source
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'

  # automatic_scaling = true
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
