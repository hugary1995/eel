n = 100
sigma = 10
alpha = 0.5
i0 = 1
F = 96485
R = 8.3145
T = 300
U = 0.1

[Mesh]
  [left]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = ${n}
    ny = 1
    boundary_name_prefix = anode
  []
  [right]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 1
    xmax = 2
    ymin = 0
    ymax = 1
    nx = ${n}
    ny = 1
    boundary_name_prefix = elyte
    boundary_id_offset = 100
  []
  [stitch]
    type = StitchedMeshGenerator
    inputs = 'left right'
    stitch_boundaries_pairs = 'anode_right elyte_left'
  []
  [rename]
    type = RenameBoundaryGenerator
    input = stitch
    old_boundary = 'anode_left elyte_right'
    new_boundary = 'left right'
  []
  [anode]
    type = SubdomainBoundingBoxGenerator
    input = rename
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_id = 0
    block_name = anode
  []
  [elyte]
    type = SubdomainBoundingBoxGenerator
    input = anode
    bottom_left = '1 0 0'
    top_right = '2 1 0'
    block_id = 1
    block_name = elyte
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = elyte
    split_interface = true
    add_interface_on_two_sides = true
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [T]
    initial_condition = ${T}
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
[]

[InterfaceKernels]
  [current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ibv
    boundary = 'anode_elyte'
  []
[]

[Functions]
  [in]
    type = ParsedFunction
    expression = '-t'
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = Phi
    boundary = left
    value = 0
  []
  [right]
    type = FunctionNeumannBC
    variable = Phi
    boundary = right
    function = in
  []
[]

[Materials]
  [electric_constants]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma}'
  []
  [charge_trasport]
    type = BulkChargeTransport
    electrical_energy_density = E
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [current]
    type = CurrentDensity
    current_density = i
    energy_densities = 'E'
    electric_potential = Phi
  []
  [OCP_anode]
    type = ADParsedMaterial
    property_name = U
    expression = '${U}'
    boundary = 'anode_elyte'
  []
  [charge_transfer_anode_elyte]
    type = ChargeTransferReaction
    charge_transfer_current_density = ibv
    charge_transfer_mass_flux = jbv
    charge_transfer_heat_flux = hbv
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = ${alpha}
    exchange_current_density = ${i0}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'anode_elyte'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  dt = 1e-3
  end_time = 1

  timestep_tolerance = 1e-10
[]

[Postprocessors]
  [Phi_r]
    type = PointValue
    variable = Phi
    point = '2 0 0'
    outputs = none
  []
  [delta_Phi]
    type = ParsedPostprocessor
    function = '-Phi_r'
    pp_names = 'Phi_r'
  []
  [in]
    type = FunctionValuePostprocessor
    function = in
  []
[]

[Outputs]
  exodus = true
[]
