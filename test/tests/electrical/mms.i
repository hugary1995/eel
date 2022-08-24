[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 0
    xmax = 1
    nx = ${n}
  []
[]

[Variables]
  [Phi]
  []
[]

[Functions]
  [Phi]
    type = ParsedFunction
    value = '3.565*exp(x)-4.71*x^2+7.1*x-3.4'
  []
  [sigma]
    type = ParsedFunction
    value = '1+x'
  []
  [q]
    type = ParsedFunction
    value = '2.32+exp(x)*(-7.13-3.565*x)+18.84*x'
  []
[]

[Kernels]
  [charge_balance]
    type = RankOneDivergence
    variable = Phi
    vector = i
  []
  [charge]
    type = BodyForce
    variable = Phi
    function = q
  []
[]

[BCs]
  [fix]
    type = FunctionDirichletBC
    variable = Phi
    boundary = 'left right'
    function = Phi
  []
[]

[Materials]
  [electric_constants]
    type = ADGenericFunctionMaterial
    prop_names = 'sigma'
    prop_values = 'sigma'
  []
  [polarization]
    type = Polarization
    electrical_energy_density = E
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = i
    electric_potential = Phi
    energy_densities = 'E'
  []
[]

[Postprocessors]
  [error]
    type = ElementL2Error
    variable = Phi
    function = Phi
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  num_steps = 1
[]

[VectorPostprocessors]
  [Phi]
    type = LineValueSampler
    variable = Phi
    start_point = '0 0 0'
    end_point = '1 0 0'
    num_points = 20
    sort_by = x
  []
  [mms]
    type = LineFunctionSampler
    functions = Phi
    start_point = '0 0 0'
    end_point = '1 0 0'
    num_points = 20
    sort_by = x
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
