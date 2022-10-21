I = 3e-3 #mA
width = 0.03 #mm
in = '${fparse -I/width}'
t0 = '${fparse -1e-2/in}'
dt = '${fparse t0/100}'

sigma = 1e-1 #mS/mm

l = 0.12

c0 = 5e-4 #mmol/mm^3
M = 2e-11

R = 8.3145 #mJ/mmol/K
T0 = 300 #K
F = 96485 #mC/mmol

[GlobalParams]
  energy_densities = 'dot(psi_c) q zeta m'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${l}
    ymin = 0
    ymax = ${width}
    nx = 60
    ny = 15
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
  [c_ref]
    initial_condition = ${c0}
  []
  [T]
    initial_condition = ${T0}
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
  # [open]
  #   type = OpenBC
  #   variable = c
  #   flux = jm
  #   boundary = 'left right'
  # []
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
    faraday_constant = ${F}
  []
  [migration_flux]
    type = MassFlux
    mass_flux = jm
    energy_densities = 'm'
    chemical_potential = mu
    outputs = exodus
  []

  # Chemical reactions
  [diffusivity]
    type = ADGenericConstantMaterial
    prop_names = 'M'
    prop_values = '${M}'
  []
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c_ref
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
  [diffusion_flux]
    type = MassFlux
    mass_flux = jd
    energy_densities = 'zeta'
    chemical_potential = mu
    outputs = exodus
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    chemical_potential = mu
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
  end_time = 100
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
