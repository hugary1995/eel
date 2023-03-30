#include "GBCavitationTransport.h"

registerMooseObject("EelApp", GBCavitationTransport);

InputParameters
GBCavitationTransport::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<MaterialPropertyName>("cavity_flux", "cavity flux");
  params.addRequiredParam<MaterialPropertyName>("cavity_nucleation_rate", "cavity nucleation rate");
  return params;
}

GBCavitationTransport::GBCavitationTransport(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _u_old(_var.slnOld()),
    _u_old_neighbor(_neighbor_var.slnOldNeighbor()),
    _j(getADMaterialProperty<Real>("cavity_flux")),
    _m(getADMaterialProperty<Real>("cavity_nucleation_rate"))
{
}

ADReal
GBCavitationTransport::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0;

  switch (type)
  {
    case Moose::Element:
      r += _test[_i][_qp] * (_u[_qp] - _u_old[_qp]) / _dt;
      r += -_test[_i][_qp] * _j[_qp];
      r += -_test[_i][_qp] * _m[_qp] / 2;
      break;
    case Moose::Neighbor:
      r += _test_neighbor[_i][_qp] * (_neighbor_value[_qp] - _u_old_neighbor[_qp]) / _dt;
      r += _test_neighbor[_i][_qp] * _j[_qp];
      r += -_test_neighbor[_i][_qp] * _m[_qp] / 2;
      break;
  }

  return r;
}
