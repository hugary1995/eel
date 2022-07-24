I = 2.4 #mA
sigma = 9.6 #mS/mm

width = 15 #mm
l0 = 0
l1 = 15
l2 = 45
l3 = 60

in = '${fparse -I/width}'

D = 1e-1

c0 = 1e-3
cm = 4e-3

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

i0 = 4e-8
U_a = 0
U_e = 0
U_c = 0.01
n = 5000

rho = 2.5e-9 #Mg/mm^3
cv = 2.7e9 #mJ/Mg/K
kappa = 0.2 #mJ/mm/K/s

tr = 1000
tf = 10000
dt = 10

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = ${l0}
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
  [cathode_elyte]
    type = BreakMeshByBlockGenerator
    input = anode_elyte
    block_pairs = '2 3'
    add_interface_on_two_sides = true
    split_interface = true
  []
[]

[Variables]
  [Phi]
  []
  [c]
    initial_condition = ${c0}
  []
  [T]
    initial_condition = ${T0}
  []
[]

[AuxVariables]
  [q]
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
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
  [energy_balance_1]
    type = ADHeatConductionTimeDerivative
    variable = T
    density_name = rho
    specific_heat = cv
  []
  [energy_balance_2]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = kappa
  []
  [heat_source]
    type = MaterialSource
    variable = T
    prop = q_jh
    coefficient = -1
  []
[]

[InterfaceKernels]
  [anode_elyte_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    boundary = 'anode_elyte elyte_anode'
  []
  [cathode_elyte_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    boundary = 'cathode_elyte elyte_cathode'
  []
  [cathode_elyte_mass]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = Je
    factor = -1
    boundary = 'cathode_elyte'
  []
  [continuity_T]
    type = InterfaceContinuity
    variable = T
    neighbor_var = T
    penalty = 1
    boundary = 'anode_elyte cathode_elyte'
  []
[]

[Functions]
  [ramp]
    type = PiecewiseLinear
    x = '0 ${tr}'
    y = '0 ${in}'
  []
[]

[BCs]
  [left]
    type = FunctionNeumannBC
    variable = Phi
    boundary = left
    function = ramp
  []
  [right]
    type = DirichletBC
    variable = Phi
    boundary = right
    value = 0
  []
[]

[Materials]
  # Thermal
  [thermal_constants]
    type = ADGenericConstantMaterial
    prop_names = 'rho cv kappa'
    prop_values = '${rho} ${cv} ${kappa}'
  []

  # Electrodynamics
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
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi
    energy_densities = 'psi_e'
  []
  [joule_heating]
    type = JouleHeating
    electric_potential = Phi
    electric_conductivity = sigma
    joule_heating = q_jh
  []

  # Chemical reactions
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
  []
  [viscous_mass_transport]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
  []
  [diffusion]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    dissipation_densities = 'delta_c'
    concentration = c
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c
  []

  # Redox
  [OCP_anode]
    type = ADParsedMaterial
    f_name = U
    function = ${U_a}
    block = 'anode'
  []
  [OCP_elyte]
    type = ADParsedMaterial
    f_name = U
    function = ${U_e}
    block = 'elyte'
  []
  [OCP_cathode]
    type = ADParsedMaterial
    f_name = U
    args = 'c'
    function = '-U_c*log(1-1/(1+exp(-n*(c-c0))))'
    constant_names = 'n c0 U_c'
    constant_expressions = '${n} ${c0} ${U_c}'
    block = 'cathode'
  []
  [charge_transfer_anode_elyte]
    type = ChargeTransferReaction
    electrode_subdomain = anode
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = Je
    electrode_electric_potential = Phi
    electrolyte_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'anode_elyte elyte_anode'
  []
  [charge_transfer_cathode_elyte]
    type = ChargeTransferReaction
    electrode_subdomain = cathode
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = Je
    electrode_electric_potential = Phi
    electrolyte_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'cathode_elyte elyte_cathode'
    outputs = exodus
  []
[]

[Postprocessors]
  [V_l]
    type = SideAverageValue
    variable = Phi
    boundary = left
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [V_r]
    type = SideAverageValue
    variable = Phi
    boundary = right
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [voltage]
    type = ParsedPostprocessor
    function = 'V_r - V_l'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C_rate]
    type = ADSideIntegralMaterialProperty
    property = ie
    boundary = cathode_elyte
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [capacity_rate]
    type = ParsedPostprocessor
    function = '-dt*C_rate/3600'
    pp_names = 'dt C_rate'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [capacity]
    type = CumulativeValuePostprocessor
    postprocessor = capacity_rate
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [c_max]
    type = NodalExtremeValue
    variable = c
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_max]
    type = NodalExtremeValue
    variable = T
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
  nl_max_its = 20

  [TimeStepper]
    type = ConstantDT
    dt = ${dt}
    cutback_factor_at_failure = 0.1
    growth_factor = 1.1
  []
  end_time = ${tf}
[]

[UserObjects]
  [kill]
    type = Terminator
    expression = 'c_max > ${cm}'
  []
[]

[Outputs]
  exodus = true
[]
