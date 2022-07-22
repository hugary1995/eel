[Problem]
  solve = false
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
  []
  [left]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'
    block_id = 1
    block_name = left
  []
  [right]
    type = SubdomainBoundingBoxGenerator
    input = left
    bottom_left = '0.5 0 0'
    top_right = '1 1 0'
    block_id = 2
    block_name = right
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = right
    block_pairs = '1 2'
    add_interface_on_two_sides = true
    split_interface = true
  []
  # [left_right]
  #   type = SideSetsBetweenSubdomainsGenerator
  #   input = right
  #   new_boundary = left_right
  #   primary_block = '1'
  #   paired_block = '2'
  # []
  # [right_left]
  #   type = SideSetsBetweenSubdomainsGenerator
  #   input = left_right
  #   new_boundary = right_left
  #   primary_block = '2'
  #   paired_block = '1'
  # []
[]

[Materials]
  [foo1]
    type = ADParsedMaterial
    f_name = F
    function = 1
    boundary = 'left_right'
    outputs = exodus
  []
  [foo2]
    type = ADParsedMaterial
    f_name = F
    function = -1
    boundary = 'right_left'
    outputs = exodus
  []
  [bar]
    type = ADParsedMaterial
    f_name = F_copy
    function = F
    material_property_names = 'F'
    boundary = 'left_right'
    outputs = exodus
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
[]
