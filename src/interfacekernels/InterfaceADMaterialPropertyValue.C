// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "InterfaceADMaterialPropertyValue.h"

registerMooseObject("EelApp", InterfaceADMaterialPropertyValue);

InputParameters
InterfaceADMaterialPropertyValue::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("Enforcing continuity across an interface");
  params.addRequiredParam<MaterialPropertyName>("mat_prop", "The material property");
  return params;
}

InterfaceADMaterialPropertyValue::InterfaceADMaterialPropertyValue(
    const InputParameters & parameters)
  : ADInterfaceKernel(parameters), _prop(getADMaterialProperty<Real>("mat_prop"))
{
}

ADReal
InterfaceADMaterialPropertyValue::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * (_u[_qp] - _prop[_qp]);

    case Moose::Neighbor:
      return _test_neighbor[_i][_qp] * (_u[_qp] - _prop[_qp]);
  }

  return 0;
}
