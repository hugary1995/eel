// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "MagnetizingField.h"
#include "EelUtils.h"

registerMooseObject("EelApp", MagnetizingField);

InputParameters
MagnetizingField::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("The magnetizing field (not to be confused with magnetic field) as a "
                             "function of magnetic vector potential.");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential",
      "The components of the magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredParam<MaterialPropertyName>("magnetic_permeability",
                                                "The magnetic permeability");
  params.addRequiredParam<MaterialPropertyName>("magnetizing_field",
                                                "The name of the magnetizing field");
  return params;
}

MagnetizingField::MagnetizingField(const InputParameters & parameters)
  : Material(parameters),
    _grad_A(adCoupledGradients("magnetic_vector_potential")),
    _mu(getADMaterialProperty<Real>("magnetic_permeability")),
    _H(declareADProperty<RealVectorValue>("magnetizing_field"))
{
  _grad_A.resize(3, &_ad_grad_zero);
}

void
MagnetizingField::computeQpProperties()
{
  auto grad_A = ADRankTwoTensor::initializeFromColumns(
      (*_grad_A[0])[_qp], (*_grad_A[1])[_qp], (*_grad_A[2])[_qp]);
  _H[_qp] = 1 / _mu[_qp] * (MathUtils::leviCivita() * grad_A);
}
