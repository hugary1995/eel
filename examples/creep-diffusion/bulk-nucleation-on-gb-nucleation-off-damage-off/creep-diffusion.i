Nr = 5e-12
Qv = 1e4

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 1
    ny = 1
    nz = 1
  []
  use_displaced_mesh = false
[]

[Materials]
  [bulk_nucleation]
    type = ADParsedMaterial
    property_name = dDelta_p/dmu
    expression = 'if(p>0,1,0) * p * Nr * exp(- ${Qv} / ${R} / T)'
    coupled_variables = 'T'
    material_property_names = 'sigma_y ep_dot Nr p mu'
  []
[]
