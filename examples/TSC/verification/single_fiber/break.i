[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/2D.msh'
  []
  # [break]
  #   type = BreakMeshBySideSet
  #   input = fmg
  #   boundaries = 'fiber'
  # []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[Kernels]
  [solidx]
    type = TotalLagrangianStressDivergence
    variable = disp_x
    component = 0
  []
  [solidy]
    type = TotalLagrangianStressDivergence
    variable = disp_y
    component = 1
  []
[]

[BCs]
  [bottom_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'bottom'
  []
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom'
  []
  [top_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'top'
  []
  [top_y]
    type = DirichletBC
    variable = disp_y
    value = -0.01
    boundary = 'top'
  []
[]

[Materials]
  [C]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1
    poissons_ratio = 0.3
  []
  [strain]
    type = ComputeLagrangianStrain
  []
  [stress]
    type = ComputeLagrangianLinearElasticStress
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08

  num_steps = 1
[]

[Outputs]
  exodus = true
[]
