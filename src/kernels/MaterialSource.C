#include "MaterialSource.h"

registerMooseObject("StingrayApp", MaterialSource);

InputParameters
MaterialSource::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("Source term defined by the material property");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  return params;
}

MaterialSource::MaterialSource(const InputParameters & parameters)
  : ADKernelValue(parameters),
    BaseNameInterface(parameters),
    _prop(getADMaterialPropertyByName<Real>(prependBaseName("prop", true)))
{
}

ADReal
MaterialSource::precomputeQpResidual()
{
  return _prop[_qp];
}
