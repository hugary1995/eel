// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ChargeTransferReaction.h"

registerMooseObject("EelApp", ChargeTransferReaction);

InputParameters
ChargeTransferReaction::validParams()
{
  InputParameters params = InterfaceMaterial::validParams();
  params.addClassDescription("The Butler-Volmer condition for current density across the "
                             "electrode/electrolyte interface.");
  params.addRequiredParam<MaterialPropertyName>("charge_transfer_current_density",
                                                "Give the current density a name");
  params.addRequiredParam<MaterialPropertyName>("charge_transfer_mass_flux",
                                                "Give the mass flux a name");
  params.addRequiredParam<MaterialPropertyName>("charge_transfer_heat_flux",
                                                "Give the heat flux a name");
  params.addRequiredParam<Real>("exchange_current_density",
                                "The exchange current density (normal to the interface) for the "
                                "electrode/electrolyte interface");
  params.addRequiredParam<Real>("charge_transfer_coefficient",
                                "The dimensionless charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar("electric_potential", "Electric potential");
  params.addRequiredCoupledVar("neighbor_electric_potential", "Neighbor electric potential");
  params.addRequiredParam<MaterialPropertyName>("open_circuit_potential",
                                                "The open-circuit potential");
  params.addParam<MaterialPropertyName>("interface_resistance",
                                        "Interface resistance. The resistance is assumed to be "
                                        "independent of the transfer current, for now.");
  params.addParam<MaterialPropertyName>("degradation", "Interface degradation");
  return params;
}

ChargeTransferReaction::ChargeTransferReaction(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    _i(declareADProperty<Real>("charge_transfer_current_density")),
    _i_old(getMaterialPropertyOld<Real>("charge_transfer_current_density")),
    _j(declareADProperty<Real>("charge_transfer_mass_flux")),
    _h(declareADProperty<Real>("charge_transfer_heat_flux")),
    _i0(getParam<Real>("exchange_current_density")),
    _alpha(getParam<Real>("charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _Phi_s(adCoupledValue("electric_potential")),
    _Phi_e(adCoupledNeighborValue("neighbor_electric_potential")),
    _U(getADMaterialProperty<Real>("open_circuit_potential")),
    _rho(isParamValid("interface_resistance") ? &getADMaterialProperty<Real>("interface_resistance")
                                              : nullptr),
    _g(isParamValid("degradation") ? &getADMaterialProperty<Real>("degradation") : nullptr)
{
}

void
ChargeTransferReaction::initQpStatefulProperties()
{
  _i[_qp] = 0;
}

void
ChargeTransferReaction::computeQpProperties()
{
  // Interface degradation (e.g., debonding)
  ADReal g = _g ? (*_g)[_qp] : 1.0;

  // Interface overpotential
  ADReal eta = g * (_Phi_s[_qp] - _Phi_e[_qp]) - _U[_qp];
  if (_rho)
    eta += (*_rho)[_qp] * _i_old[_qp];

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _alpha * _F / _R / T;
  _i[_qp] = _i0 * (std::exp(coef * eta) - std::exp(-coef * eta));

  // Mass flux
  _j[_qp] = _i[_qp] / _F;

  // Heat flux
  _h[_qp] = _i[_qp] * eta;
}
