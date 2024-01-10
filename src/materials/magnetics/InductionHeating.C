// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "InductionHeating.h"

registerMooseObject("EelApp", InductionHeating);

InputParameters
InductionHeating::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("The induction heating volumetric power");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential_real",
      "The components of the real magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential_imaginary",
      "The components of the imaginery magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredParam<MaterialPropertyName>("frequency", "The current frequency");
  params.addRequiredParam<MaterialPropertyName>("electrical_conductivity",
                                                "The electrical conductivity");
  params.addRequiredParam<MaterialPropertyName>("heat_source", "The name of the heat source");
  return params;
}

InductionHeating::InductionHeating(const InputParameters & parameters)
  : Material(parameters),
    _Are(adCoupledValues("magnetic_vector_potential_real")),
    _Aim(adCoupledValues("magnetic_vector_potential_imaginary")),
    _omega(getADMaterialProperty<Real>("frequency")),
    _sigma(getADMaterialProperty<Real>("electrical_conductivity")),
    _q(declareADProperty<Real>("heat_source"))
{
  _Are.resize(3, &_ad_zero);
  _Aim.resize(3, &_ad_zero);
}

void
InductionHeating::computeQpProperties()
{
  auto Are = ADRealVectorValue((*_Are[0])[_qp], (*_Are[1])[_qp], (*_Are[2])[_qp]);
  auto Aim = ADRealVectorValue((*_Aim[0])[_qp], (*_Aim[1])[_qp], (*_Aim[2])[_qp]);
  _q[_qp] = _sigma[_qp] * _omega[_qp] * _omega[_qp] * (Are * Are + Aim * Aim) / 2;
}
