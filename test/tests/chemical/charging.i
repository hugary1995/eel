width = 0.03 #mm
l0 = 0
l1 = 0.04
l2 = 0.07
l3 = 0.12

cmax = 1e-3 #mmol/mm^3
D = 1 #mm^2/s

R = 8.3145 #mJ/mmol/K
T0 = 300 #K

[Problem]
  kernel_coverage_check = false
  material_coverage_check = false
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = ${l0}
    xmax = ${l3}
    ymin = 0
    ymax = ${width}
    nx = 60
    ny = 15
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
  [c]
    initial_condition = ${cmax}
    block = 'cathode elyte'
  []
[]

[AuxVariables]
  [T]
    initial_condition = ${T0}
  []
[]

[Kernels]
  [mass_balance_1]
    type = MaterialSource
    variable = c
    prop = mu
    block = cathode
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = J
    block = cathode
  []
[]

[InterfaceKernels]
  [negative_mass]
    type = MaterialInterfaceNeumannBC
    variable = c
    neighbor_var = c
    prop = Je
    factor = -1e9
    boundary = 'cathode_elyte'
  []
[]

[Materials]
  # Chemical reactions
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '${D} ${D} ${D}'
    block = cathode
  []
  [viscous_mass_transport]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    block = cathode
  []
  [diffusion]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    ideal_gas_constant = ${R}
    temperature = T
    block = cathode
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    energy_densities = 'psi_m'
    dissipation_densities = 'delta_c'
    concentration = c
    block = cathode
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    energy_densities = 'psi_c'
    concentration = c
    block = cathode
  []
  [BV]
    type = ADGenericConstantMaterial
    prop_names = 'Je'
    prop_values = '1'
    boundary = 'cathode_elyte'
  []
[]

[Postprocessors]
  [c]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = cathode
  []
  [J]
    type = ADSideIntegralMaterialProperty
    property = Je
    boundary = cathode_elyte
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
    type = FunctionDT
    function = 'if(t<1, 0.01, 10)'
  []
  # end_time = 1000
  num_steps = 1
[]

[Outputs]
  exodus = true
[]
