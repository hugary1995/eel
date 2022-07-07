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
  [c+]
    [AuxKernel]
      type = FunctionAux
      function = 'x*y*z*10*t'
    []
  []
  [c-]
    [AuxKernel]
      type = FunctionAux
      function = '1-x*y*z*10*t'
    []
  []
  [c+0]
  []
  [c-0]
  []
[]

[Kernels]
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
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    first_piola_kirchhoff_stress = PK1
    energy_densities = 'psi_m'
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
