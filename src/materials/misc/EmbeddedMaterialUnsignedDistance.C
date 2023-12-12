// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "EmbeddedMaterialUnsignedDistance.h"

registerMooseObject("EelApp", EmbeddedMaterialUnsignedDistance);

InputParameters
EmbeddedMaterialUnsignedDistance::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the unsigned distance function for a material "
                             "embedding another material.");
  params.addRequiredParam<SubdomainName>("primary", "primary block id");
  params.addRequiredParam<SubdomainName>("secondary", "secondary block id");
  params.addRequiredParam<MaterialPropertyName>("distance",
                                                "Name of the unsigned distance function");
  params.addRequiredParam<MaterialPropertyName>("normal", "Name of the normal");
  return params;
}

EmbeddedMaterialUnsignedDistance::EmbeddedMaterialUnsignedDistance(const InputParameters & params)
  : Material(params),
    _dist(declareProperty<Real>("distance")),
    _normal(declareProperty<RealVectorValue>("normal")),
    _primary(_mesh.getSubdomainID(getParam<SubdomainName>("primary"))),
    _secondary(_mesh.getSubdomainID(getParam<SubdomainName>("secondary"))),
    _oepl(std::make_unique<OverlappingElementPairLocator>(
        &_mesh, &_assembly, &_fe_problem, _primary, _secondary))
{
}

void
EmbeddedMaterialUnsignedDistance::reinitDistance()
{
  _dist_data.clear();
  _normal_data.clear();
  const auto & secondary_qpoints = _oepl->secondaryQPoints();

  // Compute the unsigned distance function betweem primary element quadrature points and secondary
  // element quadrature points
  _assembly.setCurrentSubdomainID(_primary);
  for (const auto primary_elem : as_range(_mesh.getMesh().active_subdomain_elements_begin(_primary),
                                          _mesh.getMesh().active_subdomain_elements_end(_primary)))
  {
    _assembly.reinit(primary_elem);
    _dist_data[primary_elem->id()].resize(_q_point.size());
    _normal_data[primary_elem->id()].resize(_q_point.size());
    for (auto qp : index_range(_q_point))
    {
      std::vector<Real> dist;
      std::transform(secondary_qpoints.begin(),
                     secondary_qpoints.end(),
                     std::back_inserter(dist),
                     [&](const Point & p) { return (p - _q_point[qp]).norm(); });
      auto min_idx = std::min_element(dist.begin(), dist.end()) - dist.begin();
      _dist_data[primary_elem->id()][qp] = dist[min_idx];
      _normal_data[primary_elem->id()][qp] = (secondary_qpoints[min_idx] - _q_point[qp]).unit();
    }
  }
}

void
EmbeddedMaterialUnsignedDistance::computeQpProperties()
{
  _dist[_qp] = _dist_data[_current_elem->id()][_qp];
  _normal[_qp] = _normal_data[_current_elem->id()][_qp];
}
