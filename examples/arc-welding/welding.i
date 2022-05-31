t0 = 10
tm = 30
V = 0.1
end_time = 600
dtmax = 10
dt = 1

W = 40
H = 40

R = 2
q0 = 2.2e4

T_melting = '${fparse 1400+273.15}'
delta_T_pc = 50
L = 2.7e11
kappa = 25
cp = 5e8
rho = 7.8e-9
alpha = 1e-5
E = 1.9e5
nu = 0.27

htc = 5
T_inf = 300

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = ${W}
    ymax = ${H}
    nx = 40
    ny = 40
  []
  [left]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    block_name = left
    bottom_left = '0 0 0'
    top_right = '${fparse W/2} ${H} 0'
  []
  [right]
    type = SubdomainBoundingBoxGenerator
    input = left
    block_id = 1
    block_name = right
    bottom_left = '${fparse W/2} 0 0'
    top_right = '${W} ${H} 0'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = right
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
  [arc_x]
    [AuxKernel]
      type = ConstantAux
      value = '${fparse W/2}'
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [arc_y]
    [AuxKernel]
      type = ParsedAux
      expression = 'if(t<${tm}, ${H}, ${H}-${V}*(t-${tm}))'
      use_xyzt = true
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [r]
    [AuxKernel]
      type = ParsedAux
      coupled_variables = 'arc_x arc_y'
      expression = 'sqrt((x-arc_x)^2+(y-arc_y)^2)'
      use_xyzt = true
      execute_on = 'INITIAL TIMESTEP_END'
    []
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
    [CohesiveZoneMaster]
      [interface]
        strain = FINITE
        boundary = interface
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
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = left
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom'
  []
  [hconv]
    type = ADMatNeumannBC
    variable = T
    boundary = 'top bottom left right'
    value = -1
    boundary_material = qconv
  []
[]

[Functions]
  [q_ramp]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${q0}'
  []
  [yield]
    type = PiecewiseLinear
    x = '300 1000 2000'
    y = '205 180  150'
  []
[]

[Materials]
  [q_ramp]
    type = ADGenericFunctionMaterial
    prop_names = 'q_ramp'
    prop_values = 'q_ramp'
  []
  [q]
    type = ADParsedMaterial
    property_name = q
    expression = 'q_ramp*exp(-0.5*(r/R)^2)/R/sqrt(2*3.1415926)'
    material_property_names = 'q_ramp'
    coupled_variables = 'r'
    constant_names = 'R q0'
    constant_expressions = '${R} ${q0}'
    outputs = exodus
  []
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'rho kappa'
    prop_values = '${rho} ${kappa}'
  []
  [gaussian_function]
    type = ADParsedMaterial
    property_name = D
    expression = 'exp(-T*(T-Tm)^2/dT^2)/sqrt(3.1415926*dT^2)'
    coupled_variables = 'T'
    constant_names = 'Tm dT'
    constant_expressions = '${T_melting} ${delta_T_pc}'
  []
  [phi]
    type = ADParsedMaterial
    property_name = phi
    expression = 'if(T<Tm, 0, if(T<Tm+dT, (T-Tm)/dT, 1))'
    coupled_variables = 'T'
    constant_names = 'Tm dT'
    constant_expressions = '${T_melting} ${delta_T_pc}'
    outputs = exodus
  []
  [cp]
    type = ADParsedMaterial
    property_name = cp
    expression = '${cp} + ${L} * D'
    material_property_names = 'D'
  []
  [eigenstrain]
    type = ADComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal_eigenstrain
    thermal_expansion_coeff = ${alpha}
    stress_free_temperature = T_ref
    temperature = T
  []
  [C]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [plasticity]
    type = ADComputeMultipleInelasticStress
    inelastic_models = 'hardening'
  []
  [hardening]
    type = ADIsotropicPlasticityStressUpdate
    hardening_constant = 600
    yield_stress_function = yield
    temperature = T
  []
  [interface_stress]
    type = WeldedInterfaceTraction
    normal_stiffness = '${fparse 100*E}'
    tangential_stiffness = '${fparse 60*E}'
    phase = phi
    phase_history_maximum = phi_max
    residual_stiffness = 1e-6
    boundary = interface
  []
  [qconv]
    type = ADParsedMaterial
    property_name = qconv
    expression = 'htc*(T-T_inf)'
    coupled_variables = 'T'
    constant_names = 'htc T_inf'
    constant_expressions = '${htc} ${T_inf}'
    boundary = 'top bottom left right'
  []
  [hydrostatic]
    type = ADRankTwoInvariant
    property_name = hydrostatic_stress
    rank_two_tensor = stress
    invariant = Hydrostatic
    outputs = exodus
  []
  [vonmises]
    type = ADRankTwoInvariant
    property_name = vonmises_stress
    rank_two_tensor = stress
    invariant = VonMisesStress
    outputs = exodus
  []
  [plastic_strain]
    type = ADRankTwoInvariant
    property_name = ep
    rank_two_tensor = combined_inelastic_strain
    invariant = EffectiveStrain
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
  exodus = true
[]
