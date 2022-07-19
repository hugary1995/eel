I = 0.12 #mA
sigma = 2.4e-1 #mS/mm
eps = 0.1

width = 15 #mm
l0 = 0
l1 = 15
l2 = 45
l3 = 60

in = '${fparse I/width}'

D = 3e-3

c0 = 1e-3
cm = 1.5e-3

eta = 1
R = 8.3145 #mJ/mmol/K
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
  [c_a]
    initial_condition = ${c0}
    block = anode
  []
  [c_e]
    initial_condition = ${c0}
    block = elyte
  []
  [c_c]
    initial_condition = ${c0}
    block = cathode
  []
[]

[AuxVariables]
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
  [mass_balance_1_a]
    type = MaterialSource
    variable = c_a
    prop = mu
    block = anode
  []
  [mass_balance_2_a]
    type = RankOneDivergence
    variable = c_a
    vector = J
    block = anode
  []
  [mass_balance_1_e]
    type = MaterialSource
    variable = c_e
    prop = mu
    block = elyte
  []
  [mass_balance_2_e]
    type = RankOneDivergence
    variable = c_e
    vector = J
    block = elyte
  []
  [mass_balance_1_c]
    type = MaterialSource
    variable = c_c
    prop = mu
    block = cathode
  []
  [mass_balance_2_c]
    type = RankOneDivergence
    variable = c_c
    vector = J
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
    open_circuit_potential = 1.5
    electrode_concentration = c_a
    electrolyte_concentration = c_e
    maximum_concentration = ${cm}
    charge_transfer_rate = 0.5
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
    open_circuit_potential = -1.5
    electrode_concentration = c_c
    electrolyte_concentration = c_e
    maximum_concentration = ${cm}
    charge_transfer_rate = 0.5
  []
  [c_continuity_anode_elyte]
    type = HenrysLaw
    variable = c_a
    neighbor_var = c_e
    from_subdomain = anode
    to_subdomain = elyte
    boundary = anode_elyte
    ratio = 1
    penalty = 10
  []
  [c_continuity_elyte_cathode]
    type = HenrysLaw
    variable = c_e
    neighbor_var = c_c
    from_subdomain = elyte
    to_subdomain = cathode
    boundary = elyte_cathode
    ratio = 1
    penalty = 10
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
  [electric_constants_a]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${fparse eps*sigma}'
    block = anode
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
  [electric_constants_e]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma}'
    block = elyte
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
    energy_densities = 'psi_e psi_charge'
    block = elyte
  []
  [electric_constants_c]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${fparse eps*sigma}'
    block = cathode
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
  [chemical_constants]
    type = ADGenericConstantMaterial
    prop_names = 'eta'
    prop_values = '${eta}'
  []
  [viscous_mass_transport_a]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c_a
    viscosity = eta
    ideal_gas_constant = ${R}
    temperature = T
    block = anode
  []
  [diffusivity_a]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
    block = anode
  []
  [diffusion_a]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c_a
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
    block = anode
  []
  [mass_source_a]
    type = MassSource
    mass_source = mu
    dissipation_densities = 'delta_c'
    concentration = c_a
    block = anode
  []
  [mass_flux_a]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c_a
    block = anode
  []
  [viscous_mass_transport_e]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c_e
    viscosity = eta
    ideal_gas_constant = ${R}
    temperature = T
    block = elyte
  []
  [diffusivity_e]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
    block = elyte
  []
  [diffusion_e]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c_e
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
    block = elyte
  []
  [charging_e]
    type = Charging
    chemical_energy_density = psi_charge
    concentration = c_e
    charge_number = 1
    electric_conductivity = sigma
    electric_potential = Phi_e
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    block = elyte
  []
  [mass_source_e]
    type = MassSource
    mass_source = mu
    # energy_densities = 'psi_charge'
    dissipation_densities = 'delta_c'
    concentration = c_e
    block = elyte
  []
  [mass_flux_e]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c psi_charge'
    concentration = c_e
    block = elyte
  []
  [viscous_mass_transport_c]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c_c
    viscosity = eta
    ideal_gas_constant = ${R}
    temperature = T
    block = cathode
  []
  [diffusivity_c]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
    block = cathode
  []
  [diffusion_c]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c_c
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
    block = cathode
  []
  [mass_source_c]
    type = MassSource
    mass_source = mu
    dissipation_densities = 'delta_c'
    concentration = c_c
    block = cathode
  []
  [mass_flux_c]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c_c
    block = cathode
  []
[]

[Postprocessors]
  [V_l]
    type = SideAverageValue
    variable = Phi_e
    boundary = elyte_anode
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V_r]
    type = SideAverageValue
    variable = Phi_e
    boundary = elyte_cathode
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [voltage]
    type = ParsedPostprocessor
    function = 'V_l - V_r'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [capacity]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_c
    block = elyte
    execute_on = 'INITIAL TIMESTEP_END'
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

  dt = 100
  end_time = 36000
[]

[Outputs]
  exodus = true
[]
