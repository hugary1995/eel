// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "RankTwoDivergence.h"

registerMooseObject("EelApp", RankTwoDivergence);

InputParameters
RankTwoDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription(
      "This class implements the weak form for the divergence of a second order tensor");
  params.addRequiredParam<MaterialPropertyName>("tensor", "The second order tensor");
  params.addRequiredParam<unsigned int>("component",
                                        "An integer corresponding to the direction "
                                        "the variable this kernel acts in. (0 for x, "
                                        "1 for y, 2 for z)");
  params.addParam<Real>("factor", 1, "The multiplication factor");
  return params;
}

RankTwoDivergence::RankTwoDivergence(const InputParameters & params)
  : ADKernel(params),
    _tensor(getADMaterialProperty<RankTwoTensor>("tensor")),
    _component(getParam<unsigned int>("component")),
    _factor(getParam<Real>("factor"))
{
}

ADReal
RankTwoDivergence::computeQpResidual()
{
  ADReal res = _tensor[_qp].row(_component) * _grad_test[_i][_qp];

  if (getBlockCoordSystem() == Moose::COORD_RZ && _component == 0)
    res += _test[_i][_qp] / _q_point[_qp](0) * _tensor[_qp](2, 2);

  return -_factor * res;
}
