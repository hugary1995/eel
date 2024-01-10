// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "MaterialReaction.h"

registerMooseObject("EelApp", MaterialReaction);

InputParameters
MaterialReaction::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("Reaction term defined by the material property");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addParam<Real>("coefficient", 1, "Coefficient to be multiplied to the source");
  params.addCoupledVar("coupled_variable",
                       "Set this to make v a coupled variable, otherwise it will use the "
                       "kernel's nonlinear variable for v");
  return params;
}

MaterialReaction::MaterialReaction(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _prop(getADMaterialProperty<Real>("prop")),
    _coef(getParam<Real>("coefficient")),
    _v(isCoupled("coupled_variable") ? adCoupledValue("coupled_variable") : _u)
{
}

ADReal
MaterialReaction::precomputeQpResidual()
{
  return _coef * _prop[_qp] * _v[_qp];
}
