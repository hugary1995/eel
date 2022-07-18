I = 0.12 #mA
sigma = 2.4e-1 #mS/mm

width = 15 #mm
length = 75 #mm

in = '${fparse I/width}'

c0 = 1e-3 #mmol/mm^3
D = 1.4e-3 #mm^2/s

eta = 100
R = 8.4315 #mJ/mmol/K
T0 = 300 #K
Omega = 75 #mm^3/mmol
F = 96485 #mC/mmol

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${length}
    ymin = 0
    ymax = ${width}
    nx = 100
    ny = 3
  []
  [anode]
    type = SubdomainBoundingBoxGenerator
    input = battery
    block_id = 1
    block_name = anode
    bottom_left = '0 0 0'
    top_right = '${fparse length/3} ${width} 0'
  []
  [electrolyte]
    type = SubdomainBoundingBoxGenerator
    input = anode
    block_id = 2
    block_name = electrolyte
    bottom_left = '${fparse length/3} 0 0'
    top_right = '${fparse length/3*2} ${width} 0'
  []
  [cathode]
    type = SubdomainBoundingBoxGenerator
    input = electrolyte
    block_id = 3
    block_name = cathode
    bottom_left = '${fparse length/3*2} 0 0'
    top_right = '${fparse length} ${width} 0'
  []
  [anode_electrolyte]
    type = BreakMeshByBlockGenerator
    input = cathode
    block_pairs = '1 2'
    interface_name = anode_electrolyte
    add_interface_on_two_sides = true
  []
  [cathode_electrolyte]
    type = BreakMeshByBlockGenerator
    input = anode_electrolyte
    block_pairs = '2 3'
    interface_name = electrolyte_cathode
    add_interface_on_two_sides = true
  []
  [pin]
    type = ExtraNodesetGenerator
    input = cathode_electrolyte
    new_boundary = 'pin'
    coord = '${fparse length/2} 0 0'
  []
[]

[Variables]
  [Phi]
  []
  [c]
    initial_condition = ${c0}
  []
[]

[AuxVariables]
  [q1]
  []
  [q2]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[Kernels]
  [charge_balance_1]
    type = RankOneDivergence
    variable = Phi
    vector = i1
    save_in = q1
  []
  [charge_balance_2]
    type = RankOneDivergence
    variable = Phi
    vector = i2
    save_in = q2
  []
  [mass_balance_1]
    type = MaterialSource
    variable = c
    prop = mu
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = J
  []
[]

[InterfaceKernels]
  [anode_electrolyte]
    type = ButlerVolmerCondition
    variable = Phi
    neighbor_var = Phi
    boundary = anode_electrolyte
    electrode_subdomain = 1
    electrolyte_subdomain = 2
    anodic_charge_transfer_coefficient = 0.5
    cathodic_charge_transfer_coefficient = 0.5
    electric_conductivity = ${sigma}
    exchange_current_density = -1e-9
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = 0
    concentration = c
    maximum_concentration = '${fparse c0*2}'
  []
  [electrolyte_cathode]
    type = ButlerVolmerCondition
    variable = Phi
    neighbor_var = Phi
    boundary = electrolyte_cathode
    electrode_subdomain = 3
    electrolyte_subdomain = 2
    anodic_charge_transfer_coefficient = 0.5
    cathodic_charge_transfer_coefficient = 0.5
    electric_conductivity = ${sigma}
    exchange_current_density = 1e-9
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = 0
    concentration = c
    maximum_concentration = '${fparse c0*2}'
  []
  [c_continuity_anode_eletrolyte]
    type = HenrysLaw
    variable = c
    neighbor_var = c
    boundary = anode_electrolyte
    from_subdomain = 1
    to_subdomain = 2
    ratio = 1
    penalty = 1e6
  []
  [c_continuity_cathode_eletrolyte]
    type = HenrysLaw
    variable = c
    neighbor_var = c
    boundary = electrolyte_cathode
    from_subdomain = 2
    to_subdomain = 3
    ratio = 1
    penalty = 1e6
  []
[]

[BCs]
  [left]
    type = NeumannBC
    variable = c
    boundary = left
    value = '${fparse eta*Omega*R*T0*in/F}'
  []
  [right]
    type = NeumannBC
    variable = c
    boundary = right
    value = '${fparse -eta*Omega*R*T0*in/F}'
  []
  # [left]
  #   type = NeumannBC
  #   variable = Phi
  #   boundary = left
  #   value = ${in}
  # []
  # [right]
  #   type = NeumannBC
  #   variable = Phi
  #   boundary = right
  #   value = -${in}
  # []
  [pin]
    type = DirichletBC
    variable = Phi
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
  [polarization]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [electric_displacement_1]
    type = ElectricDisplacement
    electric_displacement = i1
    electric_potential = Phi
    energy_densities = 'psi_e'
  []
  [electric_displacement_2]
    type = ElectricDisplacement
    electric_displacement = i2
    electric_potential = Phi
    energy_densities = 'psi_charge'
  []
  [chemical_constants]
    type = ADGenericConstantMaterial
    prop_names = 'eta'
    prop_values = ${eta}
  []
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
  []
  [viscosity]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c
    viscosity = eta
    molar_volume = ${Omega}
    ideal_gas_constant = ${R}
    temperature = T
  []
  [ficks]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    viscosity = eta
    molar_volume = ${Omega}
    ideal_gas_constant = ${R}
    temperature = T
  []
  [charging_anode]
    type = Charging
    chemical_energy_density = psi_charge
    concentration = c
    electric_potential = Phi
    electric_conductivity = sigma
    faraday_constant = ${F}
    charge_number = -1
    viscosity = eta
    molar_volume = ${Omega}
    ideal_gas_constant = ${R}
    temperature = T
    block = anode
  []
  [charging_electrolyte]
    type = Charging
    chemical_energy_density = psi_charge
    concentration = c
    electric_potential = Phi
    electric_conductivity = sigma
    faraday_constant = ${F}
    charge_number = 1
    viscosity = eta
    molar_volume = ${Omega}
    ideal_gas_constant = ${R}
    temperature = T
    block = electrolyte
  []
  [charging_cathode]
    type = Charging
    chemical_energy_density = psi_charge
    concentration = c
    electric_potential = Phi
    electric_conductivity = sigma
    faraday_constant = ${F}
    charge_number = -1
    viscosity = eta
    molar_volume = ${Omega}
    ideal_gas_constant = ${R}
    temperature = T
    block = cathode
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    concentration = c
    energy_densities = 'psi_c psi_charge'
    dissipation_densities = 'delta_c'
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    concentration = c
    energy_densities = 'psi_c psi_charge'
    dissipation_densities = 'delta_c'
  []
[]

[Postprocessors]
  [voltage_left]
    type = SideAverageValue
    variable = Phi
    boundary = left
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [voltage_right]
    type = SideAverageValue
    variable = Phi
    boundary = right
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [voltage]
    type = ParsedPostprocessor
    function = '(voltage_left-voltage_right)'
    pp_names = 'voltage_left voltage_right'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Psi_c]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [c_min]
    type = ElementExtremeValue
    variable = c
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill]
    type = Terminator
    expression = 'c_min < ${fparse 0.01*c0}'
    message = 'No more current flow'
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

  end_time = 3600
  dt = 100
[]

[Outputs]
  exodus = true
[]
