// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "MatrixFiberElementPairLocator.h"

MatrixFiberElementPairLocator::MatrixFiberElementPairLocator(MooseMesh * mesh,
                                                             Assembly * assembly,
                                                             FEProblemBase * fe_problem,
                                                             const BoundaryID primary,
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
MatrixFiberElementPairLocator::reinit()
{
  _overlapping_elem_pairs.clear();
  _element_pair_info.clear();
  _secondary_qpoints.clear();

  auto pl = _mesh->getPointLocator();
  pl->enable_out_of_mesh_mode();
  _assembly->setCurrentSubdomainID(_secondary);

  // Get all the elements on the primary boundary (both the sideset side and the neighbor side)
  auto primary_elems = _mesh->getBoundaryActiveSemiLocalElemIds(_primary);
  auto primary_neighs = _mesh->getBoundaryActiveNeighborElemIds(_primary);

  // Loop over secondary elements
  for (const auto secondary_elem :
       as_range(_mesh->getMesh().active_subdomain_elements_begin(_secondary),
                _mesh->getMesh().active_subdomain_elements_end(_secondary)))
  {
    addElemPair(secondary_elem, primary_elems);
    addElemPair(secondary_elem, primary_neighs);
  }

  // Add ghosting
  for (auto && [e1, e2] : _overlapping_elem_pairs)
    if (e1->processor_id() != e2->processor_id())
      _fe_problem->addGhostedElem(e2->id());
}

const Elem *
MatrixFiberElementPairLocator::findPrimaryElem(
    const Point & p, const std::unordered_set<dof_id_type> & elem_ids) const
{
  for (const auto & eid : elem_ids)
  {
    const auto elem = _mesh->getMesh().elem_ptr(eid);
    if (elem->contains_point(p))
      return elem;
  }
  return nullptr;
}

void
MatrixFiberElementPairLocator::addElemPair(const Elem * secondary_elem,
                                           const std::unordered_set<dof_id_type> & primary_elems)
{
  // Get the quadrature points and weights on the secondary element
  _assembly->reinit(secondary_elem);
  const auto & qpoints = _assembly->qPoints();
  const auto & JxW = _assembly->JxW();
  const Point normal;

  // For each quadrature point, find the overlapping primary element, i.e. the element on the
  // primary subdomain that contains the quadrature point.
  for (auto i : index_range(qpoints))
  {
    const auto primary_elem = findPrimaryElem(qpoints[i], primary_elems);
    if (!primary_elem)
      mooseError("Cannot locate primary element for secondary element ",
                 secondary_elem->id(),
                 " at its quadrature point ",
                 qpoints[i]);

    std::pair<const Elem *, const Elem *> pair{primary_elem, secondary_elem};
    ElementPairInfo info(primary_elem,
                         secondary_elem,
                         {qpoints[i]},
                         {qpoints[i]},
                         {JxW[i]},
                         {JxW[i]},
                         normal,
                         normal);
    _overlapping_elem_pairs.push_back(pair);
    _element_pair_info.emplace(pair, info);
    _secondary_qpoints.push_back(qpoints[i]);
  }
}
