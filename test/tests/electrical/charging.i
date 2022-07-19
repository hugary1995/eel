I = 0.12 #mA
sigma = 2.4e-1 #mS/mm

width = 15 #mm
l0 = 0
l1 = 15
l2 = 45
l3 = 60

in = '${fparse I/width}'

cm = 1e-3

R = 8.4315 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${l3}
    ymin = 0
    ymax = ${width}
    nx = 60
    ny = 3
  []
  [anode]
    type = SubdomainBoundingBoxGenerator
    input = battery
    block_id = 1
    block_name = anode
    bottom_left = '${l0} 0 0'
    top_right = '${l1} ${width} 0'
  []
  [elyte]
    type = SubdomainBoundingBoxGenerator
    input = anode
    block_id = 2
    block_name = elyte
    bottom_left = '${l1} 0 0'
    top_right = '${l2} ${width} 0'
  []
  [cathode]
    type = SubdomainBoundingBoxGenerator
    input = elyte
    block_id = 3
    block_name = cathode
    bottom_left = '${l2} 0 0'
    top_right = '${l3} ${width} 0'
  []
  [anode_elyte]
    type = BreakMeshByBlockGenerator
    input = cathode
    block_pairs = '1 2'
    add_interface_on_two_sides = true
    split_interface = true
  []
  [elyte_cathode]
    type = BreakMeshByBlockGenerator
    input = anode_elyte
    block_pairs = '2 3'
    add_interface_on_two_sides = true
    split_interface = true
  []
  [pin]
    type = ExtraNodesetGenerator
    input = elyte_cathode
    new_boundary = 'pin'
    coord = '${fparse l3/2} 0 0'
  []
[]

[Variables]
  [Phi_a]
    block = anode
  []
  [Phi_e]
    block = elyte
  []
  [Phi_c]
    block = cathode
  []
[]

[AuxVariables]
  [c_a]
    initial_condition = 2e-4
    block = anode
  []
  [c_e]
    initial_condition = 5e-4
    block = elyte
  []
  [c_c]
    initial_condition = 8e-4
    block = cathode
  []
  [T]
    initial_condition = ${T0}
  []
[]

[Kernels]
  [charge_balance_a]
    type = RankOneDivergence
    variable = Phi_a
    vector = i
    block = anode
  []
  [charge_balance_e]
    type = RankOneDivergence
    variable = Phi_e
    vector = i
    block = elyte
  []
  [charge_balance_c]
    type = RankOneDivergence
    variable = Phi_c
    vector = i
    block = cathode
  []
[]

[InterfaceKernels]
  [anode_elyte]
    type = ButlerVolmerCondition
    variable = Phi_a
    neighbor_var = Phi_e
    boundary = anode_elyte
    anodic_charge_transfer_coefficient = 0.5
    cathodic_charge_transfer_coefficient = 0.5
    electric_conductivity = ${sigma}
    exchange_current_density = 1e-9
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = 0
    electrode_concentration = c_a
    electrolyte_concentration = c_e
    maximum_concentration = ${cm}
    charge_transfer_rate = 0
  []
  [elyte_cathode]
    type = ButlerVolmerCondition
    variable = Phi_c
    neighbor_var = Phi_e
    boundary = cathode_elyte
    anodic_charge_transfer_coefficient = 0.5
    cathodic_charge_transfer_coefficient = 0.5
    electric_conductivity = ${sigma}
    exchange_current_density = 1e-9
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = 0
    electrode_concentration = c_c
    electrolyte_concentration = c_e
    maximum_concentration = ${cm}
    charge_transfer_rate = 0
  []
[]

[BCs]
  [left]
    type = NeumannBC
    variable = Phi_a
    boundary = left
    value = ${in}
  []
  [right]
    type = NeumannBC
    variable = Phi_c
    boundary = right
    value = -${in}
  []
  [pin]
    type = DirichletBC
    variable = Phi_e
    boundary = pin
    value = 0
  []
[]

[Materials]
  [electric_constants]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma}'
  []
  [polarization_a]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi_a
    electric_conductivity = sigma
    block = anode
  []
  [electric_displacement_a]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi_a
    energy_densities = 'psi_e'
    block = anode
  []
  [polarization_e]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi_e
    electric_conductivity = sigma
    block = elyte
  []
  [electric_displacement_e]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi_e
    energy_densities = 'psi_e'
    block = elyte
  []
  [polarization_c]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi_c
    electric_conductivity = sigma
    block = cathode
  []
  [electric_displacement_c]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi_c
    energy_densities = 'psi_e'
    block = cathode
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  num_steps = 1
[]

[Outputs]
  exodus = true
[]
