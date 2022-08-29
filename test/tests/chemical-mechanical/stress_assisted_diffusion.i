# Pumping a species from left to right via stress assisted diffusion

[GlobalParams]
  energy_densities = 'dot(psi) G'
  deformation_gradient = F
  mechanical_deformation_gradient = Fm
  eigen_deformation_gradient = Fg
  swelling_deformation_gradient = Fs
[]

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
      value = 1e-3
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
    initial_condition = 1e-4
  []
  [T]
    initial_condition = 300
  []
[]

[Kernels]
  ### Chemical
  [mass_balance_time]
    type = MassBalanceTimeDerivative
    variable = c
    ideal_gas_constant = 8.3145
    temperature = T
  []
  [mass_balance_1]
    type = RankOneDivergence
    variable = c
    vector = j
  []
  [mass_balance_2]
    type = MaterialSource
    variable = c
    prop = m
  []
  ### Mechanical
  [momentum_balance_x]
    type = RankTwoDivergence
    variable = disp_x
    tensor = P
    component = 0
  []
  [momentum_balance_y]
    type = RankTwoDivergence
    variable = disp_y
    tensor = P
    component = 1
  []
  [momentum_balance_z]
    type = RankTwoDivergence
    variable = disp_z
    tensor = P
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
  [open]
    type = OpenBC
    variable = c
    boundary = 'back'
    flux = j
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
    tensor_values = '100 100 100'
  []
  [mass_diffusion]
    type = MassDiffusion
    chemical_energy_density = G
    diffusivity = D
    concentration = c
    ideal_gas_constant = 8.3145
    temperature = T
  []
  [mechanical_parameters]
    type = ADGenericConstantMaterial
    prop_names = 'lambda mu beta'
    prop_values = '1 1 1'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentration = c
    reference_concentration = c0
    molar_volume = 60
    swelling_coefficient = beta
  []
  [def_grad]
    type = MechanicalDeformationGradient
    displacements = 'disp_x disp_y disp_z'
  []
  [neohookean]
    type = NeoHookeanSolid
    elastic_energy_density = psi
    lambda = lambda
    shear_modulus = mu
    concentration = c
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = P
    deformation_gradient_rate = dot(F)
  []
  [mass_source]
    type = MassSource
    mass_source = m
    concentration = c
  []
  [mass_flux]
    type = MassFlux
    mass_flux = j
    concentration = c
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  dt = 0.001
  end_time = 0.1

  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
[]
