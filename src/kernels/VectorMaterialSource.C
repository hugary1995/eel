// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "VectorMaterialSource.h"

registerMooseObject("EelApp", VectorMaterialSource);

InputParameters
VectorMaterialSource::validParams()
{
  InputParameters params = VectorKernel::validParams();
  params.addClassDescription("Kernel to calculate the source term.");
  params.addRequiredParam<MaterialPropertyName>(
      "prop_x", "Name of the material property to provide the multiplier for the x component");
  params.addRequiredParam<MaterialPropertyName>(
      "prop_y", "Name of the material property to provide the multiplier for the y component");
  params.addRequiredParam<MaterialPropertyName>(
      "prop_z", "Name of the material property to provide the multiplier for the z component");
  params.addParam<Real>("coefficient", 1, "Coefficient to be multiplied to the source");
  return params;
}

VectorMaterialSource::VectorMaterialSource(const InputParameters & parameters)
  : VectorKernel(parameters),
    _prop_x(getMaterialProperty<Real>("prop_x")),
    _prop_y(getMaterialProperty<Real>("prop_y")),
    _prop_z(getMaterialProperty<Real>("prop_z")),
    _coef(getParam<Real>("coefficient"))
{
}

Real
VectorMaterialSource::computeQpResidual()
{
  std::cout << _test[_i][_qp] << std::endl;
  std::cout << RealVectorValue(_prop_x[_qp], _prop_y[_qp], _prop_z[_qp]) << std::endl;
  std::cout << _test[_i][_qp] * RealVectorValue(_prop_x[_qp], _prop_y[_qp], _prop_z[_qp])
            << std::endl;
  std::cout << "=================================================\n";
  return _coef * _test[_i][_qp] * RealVectorValue(_prop_x[_qp], _prop_y[_qp], _prop_z[_qp]);
}

Real
VectorMaterialSource::computeQpJacobian()
{
  return 0.0;
}
