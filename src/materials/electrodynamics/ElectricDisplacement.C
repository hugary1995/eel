// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ElectricDisplacement.h"

registerMooseObject("EelApp", ElectricDisplacement);

InputParameters
ElectricDisplacement::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("electric_potential_real", "The real electrical potential");
  params.addRequiredCoupledVar("electric_potential_imag", "The imaginary electrical potential");
  params.addRequiredParam<MaterialPropertyName>(
      "electric_permittivity_real", "Name of the real part of the electric permittivity");
  params.addRequiredParam<MaterialPropertyName>(
      "electric_permittivity_imag", "Name of the imaginary part of the electric permittivity");
  params.addRequiredParam<MaterialPropertyName>(
      "electric_displacement_real", "Name of the real part of the electric displacement");
  params.addRequiredParam<MaterialPropertyName>(
      "electric_displacement_imag", "Name of the imaginary part of the electric displacement");
  return params;
}

ElectricDisplacement::ElectricDisplacement(const InputParameters & parameters)
  : Material(parameters),
    _D_real(declareADProperty<RealVectorValue>("electric_displacement_real")),
    _D_imag(declareADProperty<RealVectorValue>("electric_displacement_imag")),
    _grad_Phi_real(adCoupledGradient("electric_potential_real")),
    _grad_Phi_imag(adCoupledGradient("electric_potential_imag")),
    _eps_real(getADMaterialProperty<Real>("electric_permittivity_real")),
    _eps_imag(getADMaterialProperty<Real>("electric_permittivity_imag"))
{
}

void
ElectricDisplacement::computeQpProperties()
{
  _D_real[_qp] = _eps_real[_qp] * _grad_Phi_real[_qp] + _eps_imag[_qp] * _grad_Phi_imag[_qp];
  _D_imag[_qp] = _eps_real[_qp] * _grad_Phi_imag[_qp] - _eps_imag[_qp] * _grad_Phi_real[_qp];
}
