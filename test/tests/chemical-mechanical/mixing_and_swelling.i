# There is no external forces in this test. The deformation comes from swelling induced by concentration changes.
# For this test, nothing is driving the chemical concentration for simplicity.

[GlobalParams]
  energy_densities = 'psi_m psi_c+ psi_c-'
  dissipation_densities = 'psi_c+* psi_c-*'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 3
    ny = 3
    nz = 3
  []
[]

[Variables]
  [c+]
    [InitialCondition]
      type = FunctionIC
      function = 'x'
    []
  []
  [c-]
    [InitialCondition]
      type = FunctionIC
      function = '1-x'
    []
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [c+0]
  []
  [c-0]
  []
  [T]
    initial_condition = 1
  []
[]

[Kernels]
  ### Chemical
  [source+]
    type = MaterialSource
    variable = c+
    prop = mu+
  []
  [source-]
    type = MaterialSource
    variable = c-
    prop = mu-
  []
  [diffusion+]
    type = RankOneDivergence
    variable = c+
    vector = J+
  []
  [diffusion-]
    type = RankOneDivergence
    variable = c-
    vector = J-
  []
  ### Mechanical
  [sdx]
    type = RankTwoDivergence
    variable = disp_x
    tensor = PK1
    component = 0
  []
  [sdy]
    type = RankTwoDivergence
    variable = disp_y
    tensor = PK1
    component = 1
  []
  [sdz]
    type = RankTwoDivergence
    variable = disp_z
    tensor = PK1
    component = 2
  []
[]

[BCs]
  [bottom_fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom'
    value = 0
  []
  [bottom_fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  []
  [bottom_fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'bottom'
    value = 0
  []
[]

[Materials]
  ### Chemical
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '1 0 0 0 1 0 0 0 1'
  []
  [properties]
    type = ADGenericConstantMaterial
    prop_names = 'eta'
    prop_values = '1'
  []
  [viscosity+]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c+*
    concentration = c+
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1e-1
  []
  [viscosity-]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c-*
    concentration = c-
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1e-3
  []
  [fick+]
    type = FicksFirstLaw
    chemical_energy_density = psi_c+
    concentration = c+
    diffusivity = D
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1e-1
  []
  [fick-]
    type = FicksFirstLaw
    chemical_energy_density = psi_c-
    concentration = c-
    diffusivity = D
    viscosity = eta
    ideal_gas_constant = 1
    temperature = T
    molar_volume = 1e-3
  []
  ### Mechanical
  [parameters]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G beta'
    prop_values = '1 1 1'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentrations = 'c+ c-'
    reference_concentrations = 'c+0 c-0'
    molar_volumes = '1e-1 1e-3'
    swelling_coefficient = beta
  []
  [def_grad]
    type = DeformationGradient
    displacements = 'disp_x disp_y disp_z'
  []
  [psi_m]
    type = NeoHookeanElasticEnergyDensity
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
    concentrations = 'c+ c-'
  []
  ### Thermodynamic forces
  [mass_source+]
    type = MassSource
    mass_source = mu+
    concentration = c+
  []
  [mass_source-]
    type = MassSource
    mass_source = mu-
    concentration = c-
  []
  [mass_flux+]
    type = MassFlux
    mass_flux = J+
    concentration = c+
  []
  [mass_flux-]
    type = MassFlux
    mass_flux = J-
    concentration = c-
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = PK1
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  dt = 0.01
  end_time = 0.1

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = true
[]
