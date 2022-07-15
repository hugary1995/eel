# From  0 to t1, the charging current is linearly ramped up.
# From t1 to t2, the charging current is kept constant.
# From t2 to t3, the charging current is linearly ramped down.
# The maximum charging current is I

I = 0.12 #mA
t1 = 1 #s
t2 = 5 #s
t3 = 6 #s
sigma = 2.4e-1 #mS/mm

width = 15 #mm
length = 50 #mm

in = '${fparse I/width}'

[Mesh]
  [battery]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${length}
    ymin = 0
    ymax = ${width}
    nx = 10
    ny = 3
  []
[]

[Variables]
  [Phi]
  []
[]

[AuxVariables]
  [q]
  []
[]

[Kernels]
  [div]
    type = RankOneDivergence
    variable = Phi
    vector = i
    save_in = q
  []
[]

[Functions]
  [in]
    type = PiecewiseLinear
    x = '0 ${t1} ${t2} ${t3}'
    y = '0 -${in} -${in} 0'
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = Phi
    boundary = left
    value = 0
  []
  [right]
    type = FunctionNeumannBC
    variable = Phi
    boundary = right
    function = in
  []
[]

[Materials]
  [constants]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma}'
  []
  [polarization]
    type = Polarization
    electrical_energy_density = psi_e
    electric_potential = Phi
    electric_conductivity = sigma
  []
  [electric_displacement]
    type = ElectricDisplacement
    electric_displacement = i
    energy_densities = 'psi_e'
    electric_potential = Phi
  []
[]

[Postprocessors]
  [voltage_left]
    type = SideAverageValue
    variable = Phi
    boundary = left
    outputs = none
  []
  [voltage_right]
    type = SideAverageValue
    variable = Phi
    boundary = right
    outputs = none
  []
  [voltage]
    type = ParsedPostprocessor
    function = 'voltage_left-voltage_right'
    pp_names = 'voltage_left voltage_right'
  []
  [charge_rate]
    type = NodalSum
    variable = q
    boundary = 'left'
    outputs = none
  []
  [dt]
    type = TimestepSize
    outputs = none
  []
  [charge_change]
    type = ParsedPostprocessor
    function = 'charge_rate*dt/1000'
    pp_names = 'charge_rate dt'
    outputs = none
  []
  [capacity]
    type = CumulativeValuePostprocessor
    postprocessor = charge_change
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  end_time = ${t3}
  dt = 0.01
[]

[Outputs]
  exodus = true
[]
