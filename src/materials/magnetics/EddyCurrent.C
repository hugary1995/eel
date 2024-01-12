// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "EddyCurrent.h"

registerMooseObject("EelApp", EddyCurrent);

InputParameters
EddyCurrent::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("The eddy current");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential_real",
      "The components of the real magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential_imaginary",
      "The components of the imaginery magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredParam<MaterialPropertyName>("frequency", "The current frequency");
  params.addRequiredParam<MaterialPropertyName>("electrical_conductivity",
                                                "The electrical conductivity");
  params.addRequiredParam<MaterialPropertyName>("current_density",
                                                "The name of the current density");
  return params;
}

EddyCurrent::EddyCurrent(const InputParameters & parameters)
  : Material(parameters),
    _Are(adCoupledValues("magnetic_vector_potential_real")),
    _Aim(adCoupledValues("magnetic_vector_potential_imaginary")),
    _omega(getADMaterialProperty<Real>("frequency")),
    _sigma(getADMaterialProperty<Real>("electrical_conductivity")),
    _ie(declareADProperty<Real>("current_density"))
{
  _Are.resize(3, &_ad_zero);
  _Aim.resize(3, &_ad_zero);
}

void
EddyCurrent::computeQpProperties()
{
  auto Are = ADRealVectorValue((*_Are[0])[_qp], (*_Are[1])[_qp], (*_Are[2])[_qp]);
  auto Aim = ADRealVectorValue((*_Aim[0])[_qp], (*_Aim[1])[_qp], (*_Aim[2])[_qp]);
  _ie[_qp] = _sigma[_qp] * _omega[_qp] * std::sqrt(Are * Are + Aim * Aim);
}
