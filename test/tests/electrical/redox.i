# In this test, an electrode-electrolyte is considered. The electrode x = [0, 0.5]
# and the electrolyte x = [0.5, 1] share an interface at x = 0.5. The electric potential
# on the left is prescribed to be 1, the electric potential on the right is prescribed
# to be 0. The Butler-Volmer condition is enforced at the interface to model redox.
# Parameters are chosen to yield a simple analytical solution:
#                  exchange current density i0 = 1
#   anodic charge transfer coefficient alpha_a = 1
# cathodic charge transfer coefficient alpha_c = 1
#                         Faraday's constant F = 1
#                         ideal gas constant R = 1
#                                temperature T = 1
#                  electric conductivity sigma = 1
# With these parameters, the analytical solution for the electric potential is
# Phi = - 1.8141 x + 1, x = [0, 0.5]
#     = - 1.8141 x + 1.8141, x = [0.5, 1]
# Hence the jump in electric potential is -0.8141.

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 2
    nz = 2
    xmax = 1
    ymax = 0.2
    zmax = 0.2
  []
  [electrolyte]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 1
    bottom_left = '0.5 0 0'
    top_right = '1 0.2 0.2'
  []
  [interface]
    type = BreakMeshByBlockGenerator
    input = electrolyte
    interface_name = interface
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [T]
    [InitialCondition]
      type = ConstantIC
      value = 1
    []
  []
  [analytical_solution]
    [AuxKernel]
      type = ParsedAux
      function = 'if(x<0.5, -1.8141*x+1, -1.8141*x+1.8141)'
      use_xyzt = true
    []
  []
[]

[Kernels]
  [div]
    type = RankOneDivergence
    variable = Phi
    vector = D
  []
[]

[InterfaceKernels]
  [redox]
    type = Redox
    variable = Phi
    neighbor_var = Phi
    boundary = interface
    electrode_subdomain = 0
    electrolyte_subdomain = 1
    anodic_charge_transfer_coefficient = 1
    cathodic_charge_transfer_coefficient = 1
    electric_conductivity = 1
    exchange_current_density = 1
    faraday_constant = 1
    ideal_gas_constant = 1
    temperature = T
    penalty = 1e2
  []
[]

[BCs]
  [left]
    type = FunctionDirichletBC
    variable = Phi
    boundary = left
    function = 't'
  []
  [right]
    type = FunctionDirichletBC
    variable = Phi
    boundary = right
    function = 0
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
  [Phi_electrode]
    type = PointValue
    variable = Phi
    point = '0.499999 0 0'
    outputs = none
  []
  [Phi_electrolyte]
    type = PointValue
    variable = Phi
    point = '0.500001 0 0'
    outputs = none
  []
  [Phi_jump]
    type = ParsedPostprocessor
    pp_names = 'Phi_electrode Phi_electrolyte'
    function = 'Phi_electrode - Phi_electrolyte'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 0.1
  end_time = 1
[]

[Outputs]
  exodus = true
[]
