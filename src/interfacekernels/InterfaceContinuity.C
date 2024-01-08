// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "InterfaceContinuity.h"
#include "Function.h"

registerMooseObject("EelApp", InterfaceContinuity);

InputParameters
InterfaceContinuity::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("Enforcing continuity across an interface");
  params.addRequiredParam<FunctionName>("penalty",
                                        "The penalty to enforce this interface condition");
  return params;
}

InterfaceContinuity::InterfaceContinuity(const InputParameters & parameters)
  : ADInterfaceKernel(parameters), _penalty(getFunction("penalty"))
{
}

ADReal
InterfaceContinuity::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty.value(_t, _q_point[_qp]) * (_u[_qp] - _neighbor_value[_qp]);

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * _penalty.value(_t, _q_point[_qp]) *
             (_u[_qp] - _neighbor_value[_qp]);
  }

  return 0;
}
