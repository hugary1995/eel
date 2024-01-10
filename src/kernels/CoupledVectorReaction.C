// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "CoupledVectorReaction.h"

registerMooseObject("EelApp", CoupledVectorReaction);

InputParameters
CoupledVectorReaction::validParams()
{
  InputParameters params = VectorKernel::validParams();
  params.addClassDescription("Vector reaction");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addParam<Real>("coefficient", 1, "Coefficient to be multiplied to the source");
  params.addRequiredCoupledVar("coupled_variable",
                               "Set this to make v a coupled variable, otherwise it will use the "
                               "kernel's nonlinear variable for v");
  return params;
}

CoupledVectorReaction::CoupledVectorReaction(const InputParameters & parameters)
  : VectorKernel(parameters),
    _prop(getMaterialProperty<Real>("prop")),
    _coef(getParam<Real>("coefficient")),
    _v(coupledVectorValue("coupled_variable")),
    _v_num(coupled("coupled_variable"))
{
}

Real
CoupledVectorReaction::computeQpResidual()
{
  return _coef * _prop[_qp] * _u[_qp] * _test[_i][_qp];
}

Real
CoupledVectorReaction::computeQpJacobian()
{
  return 0;
}

Real
CoupledVectorReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_num)
    return _coef * _prop[_qp] * _phi[_j][_qp] * _test[_i][_qp];

  return 0;
}
