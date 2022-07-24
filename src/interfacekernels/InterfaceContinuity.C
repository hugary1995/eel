#include "InterfaceContinuity.h"

registerMooseObject("StingrayApp", InterfaceContinuity);

InputParameters
InterfaceContinuity::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("Enforcing continuity across an interface");
  params.addRequiredParam<Real>("penalty", "The penalty to enforce this interface condition");
  return params;
}

InterfaceContinuity::InterfaceContinuity(const InputParameters & parameters)
  : ADInterfaceKernel(parameters), _penalty(getParam<Real>("penalty"))
{
}

ADReal
InterfaceContinuity::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty * (_u[_qp] - _neighbor_value[_qp]);

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * _penalty * (_u[_qp] - _neighbor_value[_qp]);
  }

  return 0;
}
