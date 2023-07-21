Nr = 1e-11
Qv = 5e4

Nri = 5e-12
Qvi = 1e4
Mi = 1e-8
Gc = 1e8
w = 1e-3
Ei = 1e5
Gi = 8e4

Ly = 2

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 1
    ymax = 2
    zmax = 1
    nx = 1
    ny = 2
    nz = 1
  []
  [bottom_half]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 1 1'
  []
  [top_half]
    type = SubdomainBoundingBoxGenerator
    input = bottom_half
    block_id = 1
    bottom_left = '0 1 0'
    top_right = '1 2 1'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = top_half
  []
  use_displaced_mesh = false
[]

[Modules]
  [TensorMechanics]
    [CohesiveZoneMaster]
      [interface]
        boundary = interface
        strain = SMALL
        use_automatic_differentiation = true
      []
    []
  []
[]

[InterfaceKernels]
  [gb]
    type = GBCavitationTransport
    variable = c
    neighbor_var = c
    cavity_flux = ji
    cavity_nucleation_rate = mi
    boundary = interface
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nr'
    prop_values = '${Nr}'
  []
  [bulk_nucleation]
    type = ADParsedMaterial
    property_name = dDelta_p/dmu
    expression = 'if(p>0,1,0) * p * Nr * exp(- ${Qv} / ${R} / T)'
    coupled_variables = 'T'
    material_property_names = 'sigma_y ep_dot Nr p mu'
  []
  [interface_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Nri Mi Gc Ei Gi'
    prop_values = '${Nri} ${Mi} ${Gc} ${Ei} ${Gi}'
    boundary = interface
  []
  [traction_separation]
    type = GBCavitation
    activation_energy = ${Qvi}
    cavity_flux = ji
    cavity_nucleation_rate = mi
    concentration = c
    reference_concentration = c_ref
    critical_energy_release_rate = Gc
    damage = d
    ideal_gas_constant = ${R}
    interface_width = ${w}
    mobility = M
    molar_volume = ${Omega}
    reference_nucleation_rate = Nri
    normal_stiffness = Ei
    tangential_stiffness = Gi
    swelling_coefficient = alpha
    temperature = T
    boundary = interface
  []
[]
