# Consider a uniformly charged sphere. The total charge Q is uniformly distributed
# within a radius of R. No charge is present outside R. The charge density is the
# gradient of the electric field:
# rho_q = k Q / R^3, r < R
#       = -2 k Q / r^3, r > R
# Suppose eps_0 eps_r = 1. The electric potential is then
# Phi = k Q / r, r > R;
#     = k Q / 2 / R * (3 - r^2/R^2), r < R.

R = 1
Q = 1
k = '${fparse 1/4/pi}'

[Mesh]
  [line]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 100
    xmax = '${fparse 2*R}'
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [analytical_solution]
    [AuxKernel]
      type = FunctionAux
      function = analytical_solution
    []
  []
[]

[Functions]
  [analytical_solution]
    type = ParsedFunction
    value = 'if(x>${R}, ${k}*${Q}/x, ${k}*${Q}/2/${R}*(3-x^2/${R}^2))'
  []
  [rho_q]
    type = ParsedFunction
    value = 'if(x<${R}, ${k}*${Q}/${R}^3, -2*${k}*${Q}/x^3)'
  []
[]

[Kernels]
  [div]
    type = RankOneDivergence
    variable = Phi
    vector = D
  []
  [charge]
    type = BodyForce
    variable = Phi
    function = rho_q
  []
[]

[BCs]
  [infty]
    type = FunctionDirichletBC
    variable = Phi
    boundary = right
    function = analytical_solution
  []
[]

[Materials]
  [constants]
    type = ADGenericConstantMaterial
    prop_names = 'eps_0 eps_r'
    prop_values = '1 1'
  []
  [polarization]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi
    vacuum_permittivity = eps_0
    relative_permittivity = eps_r
  []
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = D
    energy_densities = 'psi_e'
    electric_potential = Phi
  []
[]

[Postprocessors]
  [error]
    type = ElementL2Error
    variable = Phi
    function = analytical_solution
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12

  num_steps = 1
[]

[Outputs]
  exodus = true
[]
