#include "MaterialInterfaceNeumannBC.h"

registerMooseObject("EelApp", MaterialInterfaceNeumannBC);

InputParameters
MaterialInterfaceNeumannBC::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addParam<Real>("factor", 1, "The factor to be multiplied");
  return params;
}

MaterialInterfaceNeumannBC::MaterialInterfaceNeumannBC(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _mat_prop(getADMaterialProperty<Real>("prop")),
    _factor(getParam<Real>("factor"))
{
}

ADReal
MaterialInterfaceNeumannBC::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return -_test[_i][_qp] * _mat_prop[_qp] * _factor;

    case Moose::Neighbor:
      return 0;
  }

  return 0;
}
