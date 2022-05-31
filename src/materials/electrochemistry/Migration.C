// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "Migration.h"

registerMooseObject("EelApp", Migration);

InputParameters
Migration::validParams()
{
  InputParameters params = ElectroChemicalEnergyDensity::validParams();
  params.addClassDescription(
      params.getClassDescription() +
      " This class defines the electrochemical potential for the migration mechanism");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "The electric conductivity tensor");
  params.addRequiredParam<Real>("faraday_constant", "Faraday's constant");
  return params;
}

Migration::Migration(const InputParameters & parameters)
  : ElectroChemicalEnergyDensity(parameters),
    _sigma(getADMaterialProperty<Real>("electric_conductivity")),
    _F(getParam<Real>("faraday_constant"))
{
}

void
Migration::computeQpProperties()
{
  _E[_qp] = _sigma[_qp] / _F * _grad_Phi[_qp] * _grad_mu[_qp];
  _d_E_d_grad_Phi[_qp] = _sigma[_qp] / _F * _grad_mu[_qp];
  _d_E_d_grad_mu[_qp] = _sigma[_qp] / _F * _grad_Phi[_qp];
}
