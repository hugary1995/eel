// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "libmesh/quadrature_gauss.h"

#include "GhostOverlappingElements.h"

registerMooseObject("MooseApp", GhostOverlappingElements);

InputParameters
GhostOverlappingElements::validParams()
{
  InputParameters params = RelationshipManager::validParams();
  params.set<bool>("attach_geometric_early") = false;
  params.addRequiredParam<SubdomainName>("primary", "primary block id");
  params.addRequiredParam<SubdomainName>("secondary", "secondary block id");
  return params;
}

GhostOverlappingElements::GhostOverlappingElements(const InputParameters & params)
  : RelationshipManager(params),
    _primary(getParam<SubdomainName>("primary")),
    _secondary(getParam<SubdomainName>("secondary"))
{
}

GhostOverlappingElements::GhostOverlappingElements(const GhostOverlappingElements & other)
  : RelationshipManager(other), _primary(other._primary), _secondary(other._secondary)
{
}

std::string
GhostOverlappingElements::getInfo() const
{
  std::ostringstream oss;
  oss << "GhostOverlappingElements";
  return oss.str();
}

void
GhostOverlappingElements::operator()(const MeshBase::const_element_iterator & range_begin,
                                     const MeshBase::const_element_iterator & range_end,
                                     const processor_id_type p,
                                     map_type & coupled_elements)
{
  std::cout << "p = " << p << std::endl;
  mooseAssert(_moose_mesh,
              "The MOOSE mesh must be non-null in order for this relationship manager to work.");

  auto primary_id = _moose_mesh->getSubdomainID(_primary);
  auto secondary_id = _moose_mesh->getSubdomainID(_secondary);

  static const CouplingMatrix * const null_mat = nullptr;

  auto pl = _moose_mesh->getPointLocator();
  pl->enable_out_of_mesh_mode();

  FEType fe_type = _dof_map->variable_type(0);
  std::unique_ptr<FEBase> fe(FEBase::build(1, fe_type));
  QGauss qrule(1, libMesh::Order::FIRST);
  fe->attach_quadrature_rule(&qrule);
  const auto & qpoints = fe->get_xyz();

  // Loop over secondary elements
  for (const auto secondary_elem : as_range(range_begin, range_end))
  {
    if (secondary_elem->subdomain_id() != secondary_id)
      // not a secondary element
      continue;

    // Get the quadrature points on the secondary element
    fe->reinit(secondary_elem);

    // For each quadrature point, find the overlapping primary element, i.e. the element on the
    // primary subdomain that contains the quadrature point.
    const std::set<subdomain_id_type> allowed_subdomains{primary_id};
    for (auto i : index_range(qpoints))
    {
      const auto primary_elem = (*pl)(qpoints[i], &allowed_subdomains);
      if (!primary_elem)
        mooseError("Cannot locate primary element for secondary element ",
                   secondary_elem->id(),
                   " at its quadrature point ",
                   qpoints[i]);

      if (primary_elem->processor_id() != p)
      {
        std::cout << "secondary element " << secondary_elem->id() << ", qpoint: " << qpoints[i]
                  << ", coupling element " << primary_elem->id() << std::endl;
        coupled_elements.emplace(primary_elem, null_mat);
      }
    }
  }
}

bool
GhostOverlappingElements::operator>=(const RelationshipManager & other) const
{
  return dynamic_cast<const GhostOverlappingElements *>(&other);
}
