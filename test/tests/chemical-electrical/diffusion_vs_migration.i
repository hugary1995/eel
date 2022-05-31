m = 1 # larger m means more migration compared to diffusion
R = 8.3145 #mJ/mmol/K
F = 96485 #mC/mmol

I = 3e-3 #mA
width = 0.03 #mm
in = '${fparse -I/width}'
t0 = '${fparse -1e-2/in}'
dt = '${fparse t0/100}'
Vmax = 4.3 #V

vf_se = 0.3
vf_cp = 0.5
vf_ca = 0.2

sigma_a = 0.2 #mS/mm
sigma_se = 0.1 #mS/mm
sigma_cp = 0.05 #mS/mm
sigma_ca = 0.2 #mS/mm
sigma_e = ${sigma_se}
sigma_c = '${fparse vf_se*sigma_se + vf_cp*sigma_cp + vf_ca*sigma_ca}'

l0 = 0
l1 = 0.04
l2 = 0.07
l3 = 0.12

cmax = 1e-3 #mmol/mm^3
c0_a = 1e-4
c0_e = 5e-4
c0_c = 1e-3

M_a = 8e-11
M_se = '${fparse sigma_se/F/F/m}'
M_cp = 4e-14
M_ca = 1e-13
M_e = ${M_se}
M_c = '${fparse vf_se*M_se + vf_cp*M_cp + vf_ca*M_ca}'

T0 = 300 #K

i0_a = 1e-1 #mA/mm^2
i0_c = 1e-1 #mA/mm^2

[GlobalParams]
  energy_densities = 'dot(psi_c) q zeta m'
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
  [Phi]
  []
  [c]
  []
[]

[AuxVariables]
  [c_ref]
  []
  [T]
    initial_condition = ${T0}
  []
[]

[ICs]
  [c_a]
    type = ConstantIC
    variable = c
    value = ${c0_a}
    block = 'anode'
  []
  [c_e]
    type = ConstantIC
    variable = c
    value = ${c0_e}
    block = 'elyte'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${c0_c}
    block = 'cathode'
  []
  [c_ref_a]
    type = ConstantIC
    variable = c_ref
    value = ${c0_a}
    block = 'anode'
  []
  [c_ref_e]
    type = ConstantIC
    variable = c_ref
    value = ${c0_e}
    block = 'elyte'
  []
  [c_ref_c]
    type = ConstantIC
    variable = c_ref
    value = ${c0_c}
    block = 'cathode'
  []
[]

[Kernels]
  # Charge balance
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  # Mass balance
  [mass_balance_1]
    type = TimeDerivative
    variable = c
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = c
    vector = j
  []
[]

[InterfaceKernels]
  [negative_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    factor = -1
    factor_neighbor = 1
    boundary = 'cathode_elyte'
  []
  [positive_current]
    type = MaterialInterfaceNeumannBC
    variable = Phi
    neighbor_var = Phi
    prop = ie
    boundary = 'anode_elyte'
  []
[]

[Functions]
  [in]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${in}'
  []
[]

[BCs]
  [left]
    type = FunctionNeumannBC
    variable = Phi
    boundary = left
    function = in
  []
  [right]
    type = DirichletBC
    variable = Phi
    boundary = right
    value = 0
  []
  [open]
    type = OpenBC
    variable = c
    flux = jm
    boundary = 'left right'
  []
[]

[Materials]
  # Electrodynamics
  [conductivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'sigma'
    subdomain_to_prop_value = 'anode ${sigma_a} elyte ${sigma_e} cathode ${sigma_c}'
  []
  [charge_transport]
    type = BulkChargeTransport
    electrical_energy_density = q
    electric_potential = Phi
    electric_conductivity = sigma
    temperature = T
  []
  [current_density]
    type = CurrentDensity
    current_density = i
    electric_potential = Phi
  []

  # Migration
  [migration]
    type = Migration
    electrochemical_energy_density = m
    electric_potential = Phi
    chemical_potential = mu
    electric_conductivity = sigma
    faraday_constant = ${F}
  []
  [migration_flux]
    type = MassFlux
    mass_flux = jm
    energy_densities = 'm'
    chemical_potential = mu
  []

  # Chemical reactions
  [diffusivity]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'M'
    subdomain_to_prop_value = 'anode ${M_a} elyte ${M_e} cathode ${M_c}'
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c_ref
    reference_chemical_potential = 1e3
  []
  [chemical_potential]
    type = ChemicalPotential
    chemical_potential = mu
    concentration = c
  []
  [diffusion]
    type = MassDiffusion
    dual_chemical_energy_density = zeta
    chemical_potential = mu
    mobility = M
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    chemical_potential = mu
  []

  # Redox
  [ramp]
    type = ADGenericFunctionMaterial
    prop_names = 'ramp'
    prop_values = 'if(t<${t0},t/${t0},1)'
  []
  [OCP_anode_graphite]
    type = ADParsedMaterial
    property_name = U
    expression = 'x:=c/${cmax}; -(122.12*x^6-321.81*x^5+315.59*x^4-141.26*x^3+28.218*x^2-1.9057*x+0.0785)*ramp'
    coupled_variables = c
    material_property_names = 'ramp'
    boundary = 'anode_elyte'
  []
  [OCP_cathode_NMC111]
    type = ADParsedMaterial
    property_name = U
    expression = 'x:=c/${cmax}; (6.0826-6.9922*x+7.1062*x^2-5.4549e-5*exp(124.23*x-114.2593)-2.5947*x^3)*ramp'
    coupled_variables = c
    material_property_names = 'ramp'
    boundary = 'cathode_elyte'
  []
  [charge_transfer_anode_elyte]
    type = ChargeTransferReaction
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_a}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'anode_elyte'
  []
  [charge_transfer_cathode_elyte]
    type = ChargeTransferReaction
    charge_transfer_current_density = ie
    charge_transfer_mass_flux = je
    charge_transfer_heat_flux = he
    electric_potential = Phi
    neighbor_electric_potential = Phi
    charge_transfer_coefficient = 0.5
    exchange_current_density = ${i0_c}
    faraday_constant = ${F}
    ideal_gas_constant = ${R}
    temperature = T
    open_circuit_potential = U
    boundary = 'cathode_elyte'
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
  [V]
    type = ParsedPostprocessor
    function = 'V_r - V_l'
    pp_names = 'V_l V_r'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [in]
    type = FunctionValuePostprocessor
    function = in
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dt]
    type = TimestepSize
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dC]
    type = ParsedPostprocessor
    function = '-dt*in*${width}'
    pp_names = 'dt in'
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C]
    type = CumulativeValuePostprocessor
    postprocessor = dC
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [c_a_max]
    type = NodalExtremeValue
    variable = c
    value_type = max
    block = anode
  []
  [c_c_min]
    type = NodalExtremeValue
    variable = c
    value_type = min
    block = cathode
  []
  [mass_a]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = anode
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_e]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = elyte
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
    block = cathode
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[UserObjects]
  [kill]
    type = Terminator
    expression = 'V >= ${Vmax}'
    message = 'Voltage reached Vmax'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  line_search = none

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 20
  l_max_its = 150

  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
  []

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    optimal_iterations = 7
    iteration_window = 2
    growth_factor = 1.2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.2
    linear_iteration_ratio = 1000000
  []
  dtmax = 1
  end_time = 100000
[]

[Outputs]
  file_base = 'diffusion_vs_migration'
  exodus = true
  print_linear_residuals = false
[]
