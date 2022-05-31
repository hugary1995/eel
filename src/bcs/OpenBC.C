// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "OpenBC.h"

registerMooseObject("EelApp", OpenBC);

InputParameters
OpenBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("An open BC where matters can freely flow in and out.");
  params.addRequiredParam<MaterialPropertyName>("flux", "The flux");
  return params;
}

OpenBC::OpenBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _flux(getADMaterialProperty<RealVectorValue>("flux"))
{
}

ADReal
OpenBC::computeQpResidual()
{
  return _test[_i][_qp] * _flux[_qp] * _normals[_qp];
}
