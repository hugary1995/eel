fiber_r = 0.5
fiber_n = 10
fiber_A = 1

sigma_fiber = 200 # 7.1e6 # S/mm, electrical conductivity https://pubs.acs.org/doi/10.1021/nl048687z
ECR = 1e3 # Ohm mm^2, contact resistance

[Mesh]
  [fiber]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = '${fparse -0.5*fiber_r*matrix_a}'
    xmax = '${fparse 0.5*fiber_r*matrix_a}'
    nx = ${fiber_n}
    boundary_name_prefix = fiber
    boundary_id_offset = 4
  []
  [fiber_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = fiber
    block_id = 1
    block_name = fiber
    bottom_left = '${fparse -0.5*fiber_r*matrix_a} ${fparse -0.5*fiber_r*matrix_a} 0'
    top_right = '${fparse 0.5*fiber_r*matrix_a} ${fparse 0.5*fiber_r*matrix_a} 0'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'matrix_subdomain fiber_subdomain'
  []
[]

[Kernels]
  [charge_balance_fiber]
    type = RankOneDivergence
    variable = Phi
    vector = i
    factor = ${fiber_A}
    save_in = ir
    block = fiber
  []
[]

[Materials]
  [electric_constants_fiber]
    type = ADGenericConstantMaterial
    prop_names = 'sigma'
    prop_values = '${sigma_fiber}'
    block = fiber
  []
[]

[Constraints]
  # [bond]
  #   type = EqualValueEmbeddedConstraint
  #   variable = Phi
  #   primary_variable = Phi
  #   primary = matrix
  #   secondary = fiber
  #   penalty = '${fparse 1/ECR}'
  #   formulation = penalty
  # []
  [test]
    type = EmbeddedMaterialConstraint
    variable = Phi
    primary = matrix
    secondary = fiber
    resistance = ${ECR}
  []
[]
