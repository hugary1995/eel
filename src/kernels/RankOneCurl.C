// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "RankOneCurl.h"
#include "PermutationTensor.h"

registerMooseObject("EelApp", RankOneCurl);

InputParameters
RankOneCurl::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("This class implements the weak form for the curl of a vector");
  params.addRequiredParam<MaterialPropertyName>("vector", "The vector");
  params.addRequiredParam<unsigned int>("component",
                                        "An integer corresponding to the direction "
                                        "the variable this kernel acts in. (0 for x, "
                                        "1 for y, 2 for z)");
  params.addParam<Real>("factor", 1, "The multiplication factor");
  return params;
}

RankOneCurl::RankOneCurl(const InputParameters & params)
  : ADKernel(params),
    _vector(getADMaterialProperty<RealVectorValue>("vector")),
    _component(getParam<unsigned int>("component")),
    _factor(getParam<Real>("factor"))
{
}

ADReal
RankOneCurl::computeQpResidual()
{
  ADReal grad_test;

  if (_component == 0)
    grad_test = _grad_test[_i][_qp](1) - _grad_test[_i][_qp](2);
  else if (_component == 1)
    grad_test = _grad_test[_i][_qp](2) - _grad_test[_i][_qp](0);
  else if (_component == 2)
    grad_test = _grad_test[_i][_qp](0) - _grad_test[_i][_qp](1);

  return -_factor * _vector[_qp](_component) * grad_test;
}
