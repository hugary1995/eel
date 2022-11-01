in = -0.1
t0 = '${fparse -1e-2/in}'
sigma = 0.2 #mS/mm

[GlobalParams]
  energy_densities = 'q m'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 0
    xmax = 0.12
    nx = 60
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [c]
    initial_condition = 1e-4
  []
  [c_ref]
    initial_condition = 1e-4
  []
  [T]
    initial_condition = 300
  []
[]

[Kernels]
  # Charge balance
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
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
[]

[Materials]
  # Electrodynamics
  [conductivity]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma}'
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
    faraday_constant = 96485
  []
  [migration_flux]
    type = MassFlux
    mass_flux = jm
    energy_densities = 'm'
    chemical_potential = mu
  []

  # Chemical reactions
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = 8.3145
    temperature = T
    reference_concentration = c_ref
  []
  [chemical_potential]
    type = ChemicalPotential
    chemical_potential = mu
    concentration = c
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

  dt = 0.1
  end_time = 100
  steady_state_detection = true
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
