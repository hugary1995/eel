#include "RankOneDivergence.h"

registerMooseObject("StingrayApp", RankOneDivergence);

InputParameters
RankOneDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("This class implements the weak form for the divergence of a vector.");
  params.addRequiredParam<MaterialPropertyName>("vector", "The vector");
  params.addParam<Real>("factor", 1, "The multiplication factor");
  return params;
}

RankOneDivergence::RankOneDivergence(const InputParameters & params)
  : ADKernel(params),
    _vector(getADMaterialProperty<RealVectorValue>("vector")),
    _factor(getParam<Real>("factor"))
{
}

ADReal
RankOneDivergence::computeQpResidual()
{
  return -_factor * _vector[_qp] * _grad_test[_i][_qp];
}
