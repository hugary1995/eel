# Quasi-static Maxwell equation:
#   ∇ · (ε ∇φ) = 0
#
# ε is the permittivity, φ is the electric potential.
#
# In complex domain,
#   ε = ε' - jε''
#   φ = φ' + jφ''
#
# The original PDE can be split into two coupled equations:
#   ∇ · (ε' ∇φ') + ∇ · (ε'' ∇φ'') = 0
#   ∇ · (ε' ∇φ'') - ∇ · (ε'' ∇φ') = 0

!include bcs.i
!include pps.i

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = example_1.exo
  []
  [sides]
    type = SideSetsFromNormalsGenerator
    input = fmg
    new_boundary = 'top bottom left right'
    normals = '0 1 0 0 -1 0 -1 0 0 1 0 0'
    fixed_normal = true
  []
[]

[Variables]
  [phi_real]
  []
  [phi_imag]
  []
[]

[Kernels]
  [real_eq]
    type = RankOneDivergence
    variable = phi_real
    vector = _D_real
  []
  [real_eq_coupled]
    type = RankOneDivergence
    variable = phi_real
    vector = _D_imag
  []
  [imag_eq]
    type = RankOneDivergence
    variable = phi_imag
    vector = _D_imag
  []
  [imag_eq_coupled]
    type = RankOneDivergence
    variable = phi_imag
    vector = _D_real
    factor = -1
  []
[]

[Functions]
  [eps_real_A]
    type = ParsedFunction
    expression = '3'
  []
  [eps_imag_A]
    type = ParsedFunction
    expression = '0.02*(1+1000*exp(-2e6/t))'
  []
  [eps_real_B]
    type = ParsedFunction
    expression = '2.0'
  []
  [eps_imag_B]
    type = ParsedFunction
    expression = '1e-3*(1+1000*exp(-8e5/t))'
  []
[]

[Materials]
  [A]
    type = ADGenericFunctionMaterial
    prop_names = 'eps_real eps_imag'
    prop_values = 'eps_real_A eps_imag_A'
    block = mat_a
  []
  [B]
    type = ADGenericFunctionMaterial
    prop_names = 'eps_real eps_imag'
    prop_values = 'eps_real_B eps_imag_B'
    block = mat_b
  []
  [energy_real]
    type = BulkChargeTransport
    electrical_energy_density = E_real
    electric_conductivity = eps_real
    electric_potential = phi_real
  []
  [energy_imag]
    type = BulkChargeTransport
    electrical_energy_density = E_imag
    electric_conductivity = eps_imag
    electric_potential = phi_imag
  []
  [D_real]
    type = CurrentDensity
    electric_potential = phi_real
    energy_densities = E_real
    current_density = _D_real
  []
  [D_imag]
    type = CurrentDensity
    electric_potential = phi_imag
    energy_densities = E_imag
    current_density = _D_imag
  []
  [D_complex]
    type = ElectricDisplacement
    electric_potential_real = phi_real
    electric_potential_imag = phi_imag
    electric_permittivity_real = eps_real
    electric_permittivity_imag = eps_imag
    electric_displacement_real = D_real
    electric_displacement_imag = D_imag
    outputs = 'exodus'
  []
  [D_real_comps]
    type = VectorComponents
    v = D_real
  []
  [D_imag_comps]
    type = VectorComponents
    v = D_imag
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  reuse_preconditioner = true
  automatic_scaling = true
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-8
  start_time = 1000
  end_time = 500000
  dt = 5000
[]

[Outputs]
  exodus = true
  csv = true
[]
