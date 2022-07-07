F = 96485
c_m = 3e-5
Omega = 1.3e4

[Kernels]
  [source]
    type = MaterialSource
    variable = c
    prop = mu
  []
  [diff_c]
    type = RankOneDivergence
    variable = c
    vector = J
  []
  [diff_Phi]
    type = RankOneDivergence
    variable = Phi
    vector = De
  []
  [heat_td]
    type = ADHeatConductionTimeDerivative
    variable = T
    specific_heat = cv
    density_name = rho
  []
  [heat_cond]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = kappa
  []
  [joule_heating]
    type = MaterialSource
    variable = T
    prop = q
    coefficient = -1
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '0.02'
  []
  [properties]
    type = ADGenericConstantMaterial
    prop_names = 'eta eps_0 eps_r sigma rho cv kappa'
    prop_values = '1e-6 5e-6 1 3.8 3.2e-9 1.13e6 0.2'
  []
  # Chemical
  [viscosity]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c_vis
    concentration = c
    viscosity = eta
    ideal_gas_constant = 8.3145
    temperature = T
    molar_volume = ${Omega}
  []
  [fick]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    concentration = c
    diffusivity = D
    viscosity = eta
    ideal_gas_constant = 8.3145
    temperature = T
    molar_volume = ${Omega}
  []
  [charging]
    type = Charging
    chemical_energy_density = psi_charging
    concentration = c
    electric_potential = Phi
    electric_conductivity = sigma
    faraday_constant = ${F}
    viscosity = eta
    ideal_gas_constant = 8.3145
    temperature = T
    molar_volume = ${Omega}
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    concentration = c
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    concentration = c
  []
  # Electrical
  [polarization]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi
    vacuum_permittivity = eps_0
    relative_permittivity = eps_r
  []
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = De
    electric_potential = Phi
  []
  [joule_heating]
    type = JouleHeating
    joule_heating = q
    electric_potential = Phi
    electric_conductivity = sigma
  []
[]

[Postprocessors]
  [c_total]
    type = ElementIntegralVariablePostprocessor
    variable = c
    outputs = none
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [soc]
    type = ParsedPostprocessor
    pp_names = c_total
    function = 'c_total / 8 / ${c_m}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
