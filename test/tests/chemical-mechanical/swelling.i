# There is no external forces in this test. The deformation comes from swelling induced by concentration changes.
# For this test, nothing is driving the chemical concentration for simplicity. They are prescribed.

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
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [c]
    [AuxKernel]
      type = FunctionAux
      function = 'x*y*z*10*t'
    []
  []
  [c0]
  []
[]

[Kernels]
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
  [parameters]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G beta'
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
    shear_modulus = G
    deformation_gradient = F
    mechanical_deformation_gradient = Fm
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = P
    energy_densities = 'dot(psi)'
    deformation_gradient_rate = dot(F)
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  dt = 0.01
  end_time = 0.1

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = true
[]
