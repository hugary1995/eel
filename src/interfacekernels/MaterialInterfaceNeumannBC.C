// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "MaterialInterfaceNeumannBC.h"

registerMooseObject("EelApp", MaterialInterfaceNeumannBC);

InputParameters
MaterialInterfaceNeumannBC::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription("Applies a Neumann BC on both sides of the interface. The value of "
                             "the Neumann BC is specified by a material property.");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addParam<Real>("factor", 1, "The factor to be multiplied");
  params.addParam<Real>("factor_neighbor", -1, "The factor to be multiplied on the neighbor side");
  return params;
}

MaterialInterfaceNeumannBC::MaterialInterfaceNeumannBC(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _mat_prop(getADMaterialProperty<Real>("prop")),
    _factor(getParam<Real>("factor")),
    _factor_neighbor(getParam<Real>("factor_neighbor"))
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
      return -_test[_i][_qp] * _mat_prop[_qp] * _factor_neighbor;
  }

  return 0;
}
