#include "RankOneDivergence.h"

registerMooseObject("StingrayApp", RankOneDivergence);

InputParameters
RankOneDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("This class implements the weak form for the divergence of a vector.");
  params.addRequiredParam<MaterialPropertyName>("vector", "The vector");
  return params;
}

RankOneDivergence::RankOneDivergence(const InputParameters & params)
  : ADKernel(params), _vector(getADMaterialProperty<RealVectorValue>("vector"))
{
}

ADReal
RankOneDivergence::computeQpResidual()
{
  return _vector[_qp] * _grad_test[_i][_qp];
}
