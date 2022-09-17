R = 8.3145
T = 300
M = 4e-5

[GlobalParams]
  energy_densities = 'dot(psi_c) zeta'
[]

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 10
    nx = 10
  []
[]

[Variables]
  [c]
    [InitialCondition]
      type = FunctionIC
      function = '-(x-5)^2/25+1'
    []
  []
  [mu]
  []
[]

[AuxVariables]
  [c0]
    initial_condition = 1e-1
  []
  [T]
    initial_condition = ${T}
  []
[]

[Kernels]
  [mass_balance_time]
    type = CoupledTimeDerivative
    variable = mu
    v = c
  []
  [mass_balance]
    type = RankOneDivergence
    variable = mu
    vector = j
  []
  [chemical_potential]
    type = PrimalDualProjection
    variable = c
    primal_variable = dot(c)
    dual_variable = mu
  []
[]

[Materials]
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c0
  []
  [diffusion]
    type = MassDiffusion
    dual_chemical_energy_density = zeta
    chemical_potential = mu
    mobility = ${M}
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
  ignore_variables_for_autoscaling = 'c'

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20

  dt = 1
  end_time = 10
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
