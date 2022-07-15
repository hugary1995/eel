#include "HenrysLaw.h"

registerMooseObject("StingrayApp", HenrysLaw);

InputParameters
HenrysLaw::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("The Henry's law describing mass transport across an interface");
  params.addRequiredParam<Real>(
      "ratio", "Ratio between the higher concentration and the lower concentration");
  params.addRequiredParam<Real>("penalty", "The penalty to enforce this interface condition");
  params.addRequiredParam<SubdomainName>("from_subdomain",
                                         "The subdomain with a higher concentration");
  params.addRequiredParam<SubdomainName>("to_subdomain",
                                         "The subdomain with a lower concentration");
  return params;
}

HenrysLaw::HenrysLaw(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _H(getParam<Real>("ratio")),
    _penalty(getParam<Real>("penalty")),
    _from_subdomain_id(_mesh.getSubdomainID(getParam<SubdomainName>("from_subdomain"))),
    _to_subdomain_id(_mesh.getSubdomainID(getParam<SubdomainName>("to_subdomain")))
{
}

ADReal
HenrysLaw::computeQpResidual(Moose::DGResidualType type)
{
  // Concentration difference
  // ADReal diff = 0;
  // if (_current_elem->subdomain_id() == _from_subdomain_id &&
  //     _neighbor_elem->subdomain_id() == _to_subdomain_id)
  //   diff = _u[_qp] - _H * _neighbor_value[_qp];
  // else if (_current_elem->subdomain_id() == _to_subdomain_id &&
  //          _neighbor_elem->subdomain_id() == _from_subdomain_id)
  //   diff = _H * _neighbor_value[_qp] - _u[_qp];
  // else
  //   mooseError("Internal error");

  // switch (type)
  // {
  //   case Moose::Element:
  //     return _test[_i][_qp] * _penalty * diff;

  //   case Moose::Neighbor:
  //     return _test_neighbor[_i][_qp] * _penalty * diff;
  // }

  // return 0;

  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty * (_u[_qp] - _neighbor_value[_qp]);

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * _penalty * (_u[_qp] - _neighbor_value[_qp]);
  }
}
