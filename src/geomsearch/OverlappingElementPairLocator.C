// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "OverlappingElementPairLocator.h"

OverlappingElementPairLocator::OverlappingElementPairLocator(MooseMesh * mesh,
                                                             Assembly * assembly,
                                                             FEProblemBase * fe_problem,
                                                             const SubdomainID primary,
                                                             const SubdomainID secondary)
  : ElementPairLocator(0),
    _mesh(mesh),
    _assembly(assembly),
    _fe_problem(fe_problem),
    _primary(primary),
    _secondary(secondary)
{
  _elem_pairs = &_overlapping_elem_pairs;
}

void
OverlappingElementPairLocator::reinit()
{
  _overlapping_elem_pairs.clear();
  _element_pair_info.clear();

  auto pl = _mesh->getPointLocator();
  pl->enable_out_of_mesh_mode();
  _assembly->setCurrentSubdomainID(_secondary);

  // Loop over secondary elements
  for (const auto secondary_elem :
       as_range(_mesh->getMesh().active_subdomain_elements_begin(_secondary),
                _mesh->getMesh().active_subdomain_elements_end(_secondary)))
  {
    // Get the quadrature points and weights on the secondary element
    _assembly->reinit(secondary_elem);
    const auto qpoints = _assembly->qPoints().stdVector();
    const auto JxW = _assembly->JxW().stdVector();
    const Point normal;

    // For each quadrature point, find the overlapping primary element, i.e. the element on the
    // primary subdomain that contains the quadrature point.
    const std::set<subdomain_id_type> allowed_subdomains{_primary};
    for (auto i : index_range(qpoints))
    {
      const auto primary_elem = (*pl)(qpoints[i], &allowed_subdomains);
      if (!primary_elem)
        mooseError("Cannot locate primary element for secondary element ",
                   secondary_elem->id(),
                   " at its quadrature point ",
                   qpoints[i]);

      std::pair<const Elem *, const Elem *> pair{primary_elem, secondary_elem};
      ElementPairInfo info(
          primary_elem, secondary_elem, qpoints, qpoints, JxW, JxW, normal, normal);
      _overlapping_elem_pairs.push_back(pair);
      _element_pair_info.emplace(pair, info);
    }
  }
}
