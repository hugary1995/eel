W = 100
H = 80
Ht = 70
nw = 100
nh = 80
nlayer = 70
hlayer = '${fparse Ht/nlayer}'
tlayer = 10

end_time = '${fparse nlayer*tlayer}'
dtmax = 2
dt = 2

# FEP properties: I am using those of stainless steel which are apparently wrong, but whatever
kappa_fep = 25
cp_fep = 5e8
rho_fep = 7.8e-9
alpha_fep = 1e-5
E_fep = 1.9e5
nu_fep = 0.27

# liquid properties: Polyurethane resin
kappa_liquid = 0.2
cp_liquid = 1.8e8
rho_liquid = 1e-9
alpha_liquid = 0
E_liquid = 100
nu_liquid = 0.27

# solid properties: Polyurethane
kappa_solid = 0.02
cp_solid = 2.4e9
rho_solid = 5e-10
alpha_solid = 2e-4
E_solid = 100
nu_solid = 0.27

q = 0.2

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = ${W}
    ymax = ${H}
    nx = ${nw}
    ny = ${nh}
  []
  [FEP]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    block_name = FEP
    bottom_left = '0 ${Ht} 0'
    top_right = '${W} ${H} 0'
  []
  [solid]
    type = SubdomainBoundingBoxGenerator
    input = FEP
    block_id = 1
    block_name = solid
    bottom_left = '0 ${fparse Ht/2} 0'
    top_right = '${W} ${Ht} 0'
  []
  [liquid]
    type = SubdomainBoundingBoxGenerator
    input = solid
    block_id = 2
    block_name = liquid
    bottom_left = '0 0 0'
    top_right = '${W} ${fparse Ht/2} 0'
  []
  use_displaced_mesh = false
[]

[Variables]
  [T]
    initial_condition = 300
  []
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [T_ref]
    initial_condition = 300
  []
  [bunny]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = FunctionAux
      function = bunny_current
      block = 'liquid solid'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
  []
  [bunny_layer]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = FunctionAux
      function = bunny_layer
      block = 'liquid solid'
      execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
  []
[]

[Functions]
  [bunny]
    type = ImageFunction
    file = gold/bunny.png
    dimensions = '${W} ${Ht} 0'
    flip_y = true
    lower_value = 1
    upper_value = 0
    threshold = 100
  []
  [current]
    type = ParsedFunction
    expression = 'i:=ceil(t/${tlayer}); if(y>${Ht}-${hlayer}*i, 1, 0)'
  []
  [layer]
    type = ParsedFunction
    expression = 'i:=ceil(t/${tlayer}); if(y>${Ht}-${hlayer}*i, if(y<${Ht}-${hlayer}*(i-1), 1, 0), 0)'
  []
  [bunny_current]
    type = CompositeFunction
    functions = 'bunny current'
  []
  [bunny_layer]
    type = CompositeFunction
    functions = 'bunny layer'
  []
[]

[UserObjects]
  [esm]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = bunny
    criterion_type = ABOVE
    threshold = 1e-3
    subdomain_id = 1
    complement_subdomain_id = 2
    apply_initial_conditions = false
    block = 'liquid solid'
  []
[]

[Modules]
  [TensorMechanics]
    [Master]
      [all]
        strain = FINITE
        incremental = true
        temperature = T
        eigenstrain_names = thermal_eigenstrain
        use_automatic_differentiation = true
      []
    []
  []
[]

[Kernels]
  [htime]
    type = ADHeatConductionTimeDerivative
    variable = T
    density_name = rho
    specific_heat = cp
  []
  [hcond]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = kappa
  []
  [hsource]
    type = MaterialSource
    variable = T
    coefficient = -1
    prop = q
    block = 'liquid solid'
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = top
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = top
  []
  # [hconv]
  #   type = ADMatNeumannBC
  #   variable = T
  #   boundary = 'top bottom left right'
  #   value = -1
  #   boundary_material = qconv
  # []
[]

[Materials]
  [q]
    type = ADParsedMaterial
    property_name = q
    coupled_variables = 'bunny_layer'
    expression = 'bunny_layer * ${q}'
    block = 'liquid solid'
  []
  [kappa]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = kappa
    subdomain_to_prop_value = 'FEP ${kappa_fep} liquid ${kappa_liquid} solid ${kappa_solid}'
  []
  [cp]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = cp
    subdomain_to_prop_value = 'FEP ${cp_fep} liquid ${cp_liquid} solid ${cp_solid}'
  []
  [rho]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = rho
    subdomain_to_prop_value = 'FEP ${rho_fep} liquid ${rho_liquid} solid ${rho_solid}'
  []
  [eigenstrain_FEP]
    type = ADComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal_eigenstrain
    thermal_expansion_coeff = ${alpha_fep}
    stress_free_temperature = T_ref
    temperature = T
    block = FEP
  []
  [eigenstrain_liquid]
    type = ADComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal_eigenstrain
    thermal_expansion_coeff = ${alpha_liquid}
    stress_free_temperature = T_ref
    temperature = T
    block = liquid
  []
  [eigenstrain_solid]
    type = ADComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal_eigenstrain
    thermal_expansion_coeff = ${alpha_solid}
    stress_free_temperature = T_ref
    temperature = T
    block = solid
  []
  [C_FEP]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E_fep}
    poissons_ratio = ${nu_fep}
    block = FEP
  []
  [C_liquid]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E_liquid}
    poissons_ratio = ${nu_liquid}
    block = liquid
  []
  [C_solid]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E_solid}
    poissons_ratio = ${nu_solid}
    block = solid
  []
  [stress]
    type = ADComputeLinearElasticStress
  []
  [hydrostatic]
    type = ADRankTwoInvariant
    property_name = hydrostatic_stress
    rank_two_tensor = stress
    invariant = Hydrostatic
    block = solid
    outputs = exodus
  []
  [vonmises]
    type = ADRankTwoInvariant
    property_name = vonmises_stress
    rank_two_tensor = stress
    invariant = VonMisesStress
    block = solid
    outputs = exodus
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  end_time = ${end_time}
  dtmax = ${dtmax}
  dtmin = 0.01
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt}
    cutback_factor = 0.2
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    optimal_iterations = 7
    iteration_window = 2
    linear_iteration_ratio = 100000
  []
  [Predictor]
    type = SimplePredictor
    scale = 1
    skip_after_failed_timestep = true
  []

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_max_its = 12
[]

[Outputs]
  file_base = 'out/print'
  exodus = true
[]
