# Pumping a species from left to right via stress assisted diffusion

[Mesh]
  [pipe]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 2
    ny = 2
    nz = 20
    zmax = 10
  []
  [right]
    type = SideSetsFromBoundingBoxGenerator
    input = pipe
    bottom_left = '-0.10 -0.10 -0.10'
    top_right = '1.1 1.1 5.0'
    boundary_id_old = 'right'
    boundary_id_new = 11
    block_id = 0
  []
  [top]
    type = SideSetsFromBoundingBoxGenerator
    input = right
    bottom_left = '-0.10 -0.10 -0.10'
    top_right = '1.1 1.1 5.0'
    boundary_id_old = 'top'
    boundary_id_new = 12
    block_id = 0
  []
[]

[Variables]
  [c]
    [InitialCondition]
      type = ConstantIC
      value = 0.5
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
  [c0]
    [InitialCondition]
      type = ConstantIC
      value = 0.5
    []
  []
[]

[Kernels]
  ### Chemical
  [source]
    type = MaterialSource
    variable = c
    prop = mu
  []
  [diffusion]
    type = RankOneDivergence
    variable = c
    vector = J
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
  [x_fix]
    type = DirichletBC
    variable = disp_x
    boundary = 4
    value = 0.0
  []
  [y_fix]
    type = DirichletBC
    variable = disp_y
    boundary = 1
    value = 0.0
  []
  [z_fix]
    type = DirichletBC
    variable = disp_z
    boundary = 0
    value = 0.0
  []
  [push_x]
    type = FunctionNeumannBC
    variable = disp_x
    boundary = 11
    function = ramp
  []
  [push_y]
    type = FunctionNeumannBC
    variable = disp_y
    boundary = 12
    function = ramp
  []
[]

[Functions]
  [ramp]
    type = PiecewiseLinear
    x = '0 0.05'
    y = '0 1'
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantRankTwoTensor
    tensor_name = 'D'
    tensor_values = '100 0 0 0 100 0 0 0 100'
  []
  [properties]
    type = ADGenericConstantMaterial
    prop_names = 'eta'
    prop_values = '1'
  []
  [viscosity]
    type = ViscousMassTransport
    chemical_dissipation_density = psi_c*
    viscosity = eta
    concentration = c
  []
  [fick]
    type = FicksFirstLaw
    chemical_energy_density = psi_c
    diffusivity = D
    concentration = c
  []
  [mechanical_parameters]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G beta omega'
    prop_values = '1 1 1 1e-1'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentrations = 'c'
    reference_concentrations = 'c0'
    molar_volumes = 'omega'
    swelling_coefficient = beta
  []
  [def_grad]
    type = DeformationGradient
    displacements = 'disp_x disp_y disp_z'
  []
  [neo_hookean]
    type = NeoHookeanElasticEnergyDensity
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
    concentrations = 'c'
  []
  [mass_source]
    type = MassSource
    mass_source = mu
    concentration = c
    energy_densities = 'psi_m psi_c'
    dissipation_densities = 'psi_c*'
  []
  [mass_flux]
    type = MassFlux
    mass_flux = J
    concentration = c
    energy_densities = 'psi_m psi_c'
    dissipation_densities = 'psi_c*'
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = PK1
    energy_densities = 'psi_m psi_c'
    dissipation_densities = 'psi_c*'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  dt = 0.01
  end_time = 0.1

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
[]

[Outputs]
  exodus = true
[]
