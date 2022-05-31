// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "EntropicChemicalEnergyDensity.h"

registerMooseObject("EelApp", EntropicChemicalEnergyDensity);

InputParameters
EntropicChemicalEnergyDensity::validParams()
{
  InputParameters params = ChemicalEnergyDensity::validParams();
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar(
      "reference_concentration",
      "The reference concentration at which the entropic chemical energy density is zero");
  params.addRequiredParam<MaterialPropertyName>("reference_chemical_potential",
                                                "reference chemical potential");
  return params;
}

EntropicChemicalEnergyDensity::EntropicChemicalEnergyDensity(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _c0(coupledValue("reference_concentration")),
    _mu0(getADMaterialProperty<Real>("reference_chemical_potential"))
{
}

void
EntropicChemicalEnergyDensity::computeQpProperties()
{
  _d_psi_dot_d_c_dot[_qp] = _mu0[_qp] + _R * _T[_qp] * std::log(_c[_qp] / _c0[_qp]);
  _psi_dot[_qp] = _d_psi_dot_d_c_dot[_qp] * _c_dot[_qp];
}
