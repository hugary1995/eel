[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 1
    ymax = 1
    zmax = 1
    nx = 2
    ny = 2
    nz = 2
  []
  [bottom_half]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 0.5 1'
  []
  [top_half]
    type = SubdomainBoundingBoxGenerator
    input = bottom_half
    block_id = 1
    bottom_left = '0 0.5 0'
    top_right = '1 1 1'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = top_half
    add_interface_on_two_sides = true
  []
  use_displaced_mesh = false
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [c]
  []
[]

[Kernels]
  [null_1]
    type = NullKernel
    variable = disp_x
  []
  [null_2]
    type = NullKernel
    variable = disp_y
  []
  [null_3]
    type = NullKernel
    variable = disp_z
  []
  [null_4]
    type = NullKernel
    variable = c
  []
[]

[InterfaceKernels]
  [gb]
    type = IKTest
    variable = c
    neighbor_var = c
    boundary = interface
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1
  dt = 0.1
  num_steps = 5

[]
