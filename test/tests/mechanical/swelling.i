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
    type = StressDivergence
    variable = disp_x
    component = 0
  []
  [sdy]
    type = StressDivergence
    variable = disp_y
    component = 1
  []
  [sdz]
    type = StressDivergence
    variable = disp_z
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
    prop_names = 'lambda G beta Omega_c+ Omega_c-'
    prop_values = '1 1 1 1e-1 1e-3'
  []
  [swelling]
    type = Swelling
    chemical_species_concentrations = 'c+ c-'
    chemical_species_reference_concentrations = 'c+0 c-0'
    molar_volumes = 'Omega_c+ Omega_c-'
    swelling_coefficient = beta
    swelling_eigen_deformation_gradient = Fs
  []
  [def_grad]
    type = DeformationGradient
    displacements = 'disp_x disp_y disp_z'
    eigen_deformation_gradient_names = 'Fs'
  []
  [psi_e]
    type = NeoHookeanElasticEnergyDensity
    elastic_energy_density = psi_e
    lambda = lambda
    shear_modulus = G
  []
  [pk1_stress]
    type = FirstPiolaKirchhoffStress
    energy_densities = 'psi_e'
  []
[]

[Executioner]
  type = Transient

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
