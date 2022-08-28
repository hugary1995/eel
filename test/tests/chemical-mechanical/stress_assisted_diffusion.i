# Pumping a species from left to right via stress assisted diffusion

[GlobalParams]
  energy_densities = 'dot(psi) G'
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
    initial_condition = 0.005
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
    boundary = 'left front'
    value = 0.0
  []
  [y_fix]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom front'
    value = 0.0
  []
  [z_fix]
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0.0
  []
  [push_z]
    type = FunctionNeumannBC
    variable = disp_z
    boundary = front
    function = ramp
  []
[]

[Functions]
  [ramp]
    type = PiecewiseLinear
    x = '0 0.05'
    y = '0 -1'
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
    swelling_deformation_gradient = Fs
    concentration = c
    reference_concentration = c0
    molar_volume = 0.1
    swelling_coefficient = beta
  []
  [def_grad]
    type = MechanicalDeformationGradient
    deformation_gradient = F
    mechanical_deformation_gradient = Fm
    swelling_deformation_gradient = Fs
    displacements = 'disp_x disp_y disp_z'
  []
  [neohookean]
    type = NeoHookeanSolid
    elastic_energy_density = psi
    lambda = lambda
    shear_modulus = mu
    deformation_gradient = F
    mechanical_deformation_gradient = Fm
    swelling_deformation_gradient = Fs
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

  dt = 0.01
  end_time = 0.1

  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_material_props = true
[]
