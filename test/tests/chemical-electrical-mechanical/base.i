F = 96485
c_m = 7.5e-5

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
  [div_stress_x]
    type = RankTwoDivergence
    variable = disp_x
    tensor = PK1
    component = 0
  []
  [div_stress_y]
    type = RankTwoDivergence
    variable = disp_y
    tensor = PK1
    component = 1
  []
[]

[BCs]
  [x_left]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  []
  [y_left]
    type = DirichletBC
    variable = disp_y
    boundary = 'left'
    value = 0
  []
  [x_right]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0
  []
  [y_right]
    type = DirichletBC
    variable = disp_y
    boundary = 'right'
    value = 0
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
    prop_names = 'eta eps_0 eps_r sigma'
    prop_values = '1 5e-7 1 6.5'
  []
  # Chemical
  [viscosity]
    type = ViscousMassTransport
    chemical_dissipation_density = delta_c_vis
    viscosity = eta
    concentration = c
  []
  [fick]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    diffusivity = D
    concentration = c
  []
  [joule_heating]
    type = JouleHeating
    chemical_dissipation_density = delta_c_jh
    concentration = c
    electric_potential = Phi
    electric_conductivity = sigma
    faraday_constant = ${F}
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
  # Mechanical
  [parameters]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G beta Omega'
    prop_values = '9.8e4 6.5e4 0.05 1.3e4'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentrations = 'c'
    reference_concentrations = '0'
    molar_volumes = 'Omega'
    swelling_coefficient = beta
  []
  [def_grad]
    type = DeformationGradient
    displacements = 'disp_x disp_y'
  []
  [psi_m]
    type = NeoHookeanElasticEnergyDensity
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = PK1
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
