#include "RankTwoDivergence.h"

registerMooseObject("StingrayApp", RankTwoDivergence);

InputParameters
RankTwoDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class implements the weak form for the divergence of a second order tensor");
  params.addRequiredParam<MaterialPropertyName>("tensor", "The second order tensor");
  params.addRequiredParam<unsigned int>("component",
                                        "An integer corresponding to the direction "
                                        "the variable this kernel acts in. (0 for x, "
                                        "1 for y, 2 for z)");
  return params;
}

RankTwoDivergence::RankTwoDivergence(const InputParameters & params)
  : ADKernel(params),
    BaseNameInterface(params),
    _tensor(getADMaterialProperty<RankTwoTensor>(prependBaseName("tensor", true))),
    _component(getParam<unsigned int>("component"))
{
}

ADReal
RankTwoDivergence::computeQpResidual()
{
  return _tensor[_qp].row(_component) * _grad_test[_i][_qp];
}
