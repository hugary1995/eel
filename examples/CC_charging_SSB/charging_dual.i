cmin_a = 1e-4 #mmol/mm^3
c_e = 2e-3 #mmol/mm^3
cmax_c = 4e-3 #mmol/mm^3

R = 8.3145 #mJ/mmol/K
T0 = 300 #K

E_cp = 1e5
E_cm = 5e4
E_e = 1e4
E_a = 2e5
nu_cp = 0.3
nu_cm = 0.25
nu_e = 0.25
nu_a = 0.3

Omega = 60
beta = 0.5
CTE = 1e-5

[GlobalParams]
  energy_densities = 'dot(psi_m) dot(psi_c)'
  deformation_gradient = F
  mechanical_deformation_gradient = Fm
  eigen_deformation_gradient = Fg
  swelling_deformation_gradient = Fs
  thermal_deformation_gradient = Ft
[]

[Mesh]
  [battery]
    type = FileMeshGenerator
    file = 'gold/ssb.msh'
  []
  [interfaces]
    type = BreakMeshByBlockGenerator
    input = battery
    add_interface_on_two_sides = true
    split_interface = true
  []
[]

[Variables]
  [mu]
  []
[]

[AuxVariables]
  [disp_x]
  []
  [disp_y]
  []
  [T]
  []
  [c]
  []
  [c_ref]
  []
  [T_ref]
    initial_condition = ${T0}
  []
[]

[ICs]
  [c_a]
    type = ConstantIC
    variable = c
    value = ${cmin_a}
    block = 'a'
  []
  [c_e]
    type = ConstantIC
    variable = c
    value = ${c_e}
    block = 'cm e'
  []
  [c_c]
    type = ConstantIC
    variable = c
    value = ${cmax_c}
    block = 'cp'
  []
  [c_ref_a]
    type = ConstantIC
    variable = c_ref
    value = ${cmin_a}
    block = 'a'
  []
  [c_ref_e]
    type = ConstantIC
    variable = c_ref
    value = ${c_e}
    block = 'cm e'
  []
  [c_ref_c]
    type = ConstantIC
    variable = c_ref
    value = ${cmax_c}
    block = 'cp'
  []
[]

[Kernels]
  # Mass balance
  [mass_balance_1]
    type = CoupledTimeDerivative
    variable = mu
    v = c
  []
  [mass_balance_2]
    type = RankOneDivergence
    variable = mu
    vector = j
  []
[]

[Materials]
  # Chemical reactions
  [chemical_energy]
    type = EntropicChemicalEnergyDensity
    chemical_energy_density = psi_c
    concentration = c
    ideal_gas_constant = ${R}
    temperature = T
    reference_concentration = c_ref
  []

  # Mechanical
  [stiffness_cp]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_cp*nu_cp/(1+nu_cp)/(1-2*nu_cp)} ${fparse E_cp/2/(1+nu_cp)}'
    block = cp
  []
  [stiffness_cm]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_cm*nu_cm/(1+nu_cm)/(1-2*nu_cm)} ${fparse E_cm/2/(1+nu_cm)}'
    block = cm
  []
  [stiffness_e]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_e*nu_e/(1+nu_e)/(1-2*nu_e)} ${fparse E_e/2/(1+nu_e)}'
    block = e
  []
  [stiffness_a]
    type = ADGenericConstantMaterial
    prop_names = 'lambda G'
    prop_values = '${fparse E_a*nu_a/(1+nu_a)/(1-2*nu_a)} ${fparse E_a/2/(1+nu_a)}'
    block = a
  []
  [swelling_coefficient]
    type = ADGenericConstantMaterial
    prop_names = 'beta'
    prop_values = '${beta}'
  []
  [swelling]
    type = SwellingDeformationGradient
    concentration = c
    reference_concentration = c_ref
    molar_volume = ${Omega}
    swelling_coefficient = beta
  []
  [thermal_expansion]
    type = ThermalDeformationGradient
    temperature = T
    reference_temperature = T_ref
    CTE = ${CTE}
  []
  [defgrad]
    type = MechanicalDeformationGradient
    displacements = 'disp_x disp_y'
  []
  [neohookean]
    type = NeoHookeanSolid
    elastic_energy_density = psi_m
    lambda = lambda
    shear_modulus = G
    concentration = c
    temperature = T
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 20
  l_max_its = 150

  dt = 1e12
  end_time = 100000
[]
