// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "MagnetizingTensor.h"
#include "EelUtils.h"

registerMooseObject("EelApp", MagnetizingTensor);

InputParameters
MagnetizingTensor::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("The magnetizing tensor");
  params.addRequiredCoupledVar(
      "magnetic_vector_potential",
      "The components of the magnetic vector potential, in the order of x, y, and z.");
  params.addRequiredParam<MaterialPropertyName>("magnetic_permeability",
                                                "The magnetic permeability");
  params.addRequiredParam<MaterialPropertyName>("magnetizing_tensor",
                                                "The name of the magnetizing field");
  return params;
}

MagnetizingTensor::MagnetizingTensor(const InputParameters & parameters)
  : Material(parameters),
    _A(adCoupledValues("magnetic_vector_potential")),
    _grad_A(adCoupledGradients("magnetic_vector_potential")),
    _mu(getADMaterialProperty<Real>("magnetic_permeability")),
    _H(declareADProperty<RankTwoTensor>("magnetizing_tensor"))
{
  _A.resize(3, &_ad_zero);
  _grad_A.resize(3, &_ad_grad_zero);
}

void
MagnetizingTensor::computeQpProperties()
{
  auto grad_A = ADRankTwoTensor::initializeFromRows(
      (*_grad_A[0])[_qp], (*_grad_A[1])[_qp], (*_grad_A[2])[_qp]);

  if (getBlockCoordSystem() == Moose::COORD_RZ)
    grad_A(2, 2) = (*_A[0])[_qp] / _q_point[_qp](0);

  _H[_qp] = 1 / _mu[_qp] * grad_A;
}
