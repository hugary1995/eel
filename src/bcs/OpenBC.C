#include "OpenBC.h"

registerMooseObject("EelApp", OpenBC);

InputParameters
OpenBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addRequiredParam<MaterialPropertyName>("flux", "The flux");
  return params;
}

OpenBC::OpenBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _flux(getADMaterialProperty<RealVectorValue>("flux"))
{
}

ADReal
OpenBC::computeQpResidual()
{
  return -_test[_i][_qp] * _flux[_qp] * _normals[_qp];
}
