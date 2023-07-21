// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "NoPenetration.h"

registerMooseObject("EelApp", NoPenetration);

InputParameters
NoPenetration::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("Preventing interface copenetration");
  params.addRequiredParam<Real>("penalty", "The penalty to enforce this interface condition");
  params.addRequiredParam<unsigned int>("component", "component");
  return params;
}

NoPenetration::NoPenetration(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _penalty(getParam<Real>("penalty")),
    _component(getParam<unsigned int>("component")),
    _interface_displacement_jump(
        getADMaterialProperty<RealVectorValue>("interface_displacement_jump")),
    _R(getADMaterialProperty<RankTwoTensor>("czm_total_rotation"))
{
}

ADReal
NoPenetration::computeQpResidual(Moose::DGResidualType type)
{
  if (_interface_displacement_jump[_qp](0) >= 0)
    return 0;

  ADRealVectorValue ju_local(_interface_displacement_jump[_qp](0), 0, 0);
  ADRealVectorValue ju_global = _R[_qp] * ju_local;

  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty * ju_global(_component) * ju_global(_component);

    case Moose::Neighbor:
      return _test_neighbor[_i][_qp] * _penalty * ju_global(_component) * ju_global(_component);
  }

  return 0;
}
