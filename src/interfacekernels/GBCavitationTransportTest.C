#include "GBCavitationTransportTest.h"

// #include "Assembly.h"

registerMooseObject("EelApp", GBCavitationTransportTest);

InputParameters
GBCavitationTransportTest::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredCoupledVar("chemical_potential", "chemical potential");
  params.addRequiredParam<MaterialPropertyName>("cavity_nucleation_rate", "cavity nucleation rate");
  params.addRequiredParam<Real>("interface_width",
                                "A fictitious interface width for scaling purposes");
  params.addRequiredParam<MaterialPropertyName>("mobility", "mobility");
  return params;
}

GBCavitationTransportTest::GBCavitationTransportTest(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _u_old(_var.slnOld()),
    _u_old_neighbor(_neighbor_var.slnOldNeighbor()),
    _M(getADMaterialProperty<Real>("mobility")),
    _grad_mu(adCoupledGradient("chemical_potential")),
    _m(getADMaterialProperty<Real>("cavity_nucleation_rate")),
    _w(getParam<Real>("interface_width"))
{
}

ADReal
GBCavitationTransportTest::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0;

  switch (type)
  {
    case Moose::Element:
      r += _test[_i][_qp] * (_u[_qp] - _u_old[_qp]) / _dt;
      r += _grad_test[_i][_qp] * _M[_qp] * _grad_mu[_qp];
      r += -_test[_i][_qp] * _m[_qp] / 2;
      break;
    case Moose::Neighbor:
      r += _test_neighbor[_i][_qp] * (_neighbor_value[_qp] - _u_old_neighbor[_qp]) / _dt;
      r += _grad_test_neighbor[_i][_qp] * _M[_qp] * _grad_mu[_qp];
      r += -_test_neighbor[_i][_qp] * _m[_qp] / 2;
      break;
  }

  return r * _w;
}
