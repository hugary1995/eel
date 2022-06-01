#include "StressDivergence.h"

registerMooseObject("StingrayApp", StressDivergence);

InputParameters
StressDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class implements the weak form for the divergence of the first "
                             "Piola-Kirchhoff stress.");
  params.addRequiredParam<unsigned int>("component",
                                        "An integer corresponding to the direction "
                                        "the variable this kernel acts in. (0 for x, "
                                        "1 for y, 2 for z)");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

StressDivergence::StressDivergence(const InputParameters & params)
  : ADKernel(params),
    BaseNameInterface(params),
    _PK1(getADMaterialProperty<RankTwoTensor>(prependBaseName("first_piola_kirchhoff_stress"))),
    _component(getParam<unsigned int>("component"))
{
}

ADReal
StressDivergence::computeQpResidual()
{
  return _PK1[_qp].row(_component) * _grad_test[_i][_qp];
}
