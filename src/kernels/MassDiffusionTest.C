// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "MassDiffusionTest.h"

registerMooseObject("EelApp", MassDiffusionTest);

InputParameters
MassDiffusionTest::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("This class implements the weak form for the divergence of a vector.");
  params.addRequiredCoupledVar("chemical_potential", "chemical potential");
  params.addRequiredParam<MaterialPropertyName>("mobility", "mobility");
  return params;
}

MassDiffusionTest::MassDiffusionTest(const InputParameters & params)
  : ADKernel(params),
    _grad_mu(adCoupledGradient("chemical_potential")),
    _M(getADMaterialProperty<Real>("mobility"))
{
}

ADReal
MassDiffusionTest::computeQpResidual()
{
  return _grad_test[_i][_qp] * _M[_qp] * _grad_mu[_qp];
}
