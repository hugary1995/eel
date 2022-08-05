#include "ChargeTransferReaction.h"

registerMooseObject("StingrayApp", ChargeTransferReaction);

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
  params.addRequiredParam<Real>("exchange_current_density",
                                "The exchange current density (normal to the interface) for the "
                                "electrode/electrolyte interface");
  params.addRequiredParam<Real>("charge_transfer_coefficient",
                                "The dimensionless charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar("electric_potential", "Electric potential");
  params.addRequiredParam<MaterialPropertyName>("open_circuit_potential",
                                                "The open-circuit potential");
  params.addRequiredParam<bool>("electrode", "Am I electrode? Set to false for electrolyte.");
  return params;
}

ChargeTransferReaction::ChargeTransferReaction(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    _i(declareADProperty<Real>(getParam<MaterialPropertyName>("charge_transfer_current_density"))),
    _j(declareADProperty<Real>(getParam<MaterialPropertyName>("charge_transfer_mass_flux"))),
    _electrode(getParam<bool>("electrode")),
    _i0(getParam<Real>("exchange_current_density")),
    _alpha(getParam<Real>("charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _Phi_s(_electrode ? adCoupledValue("electric_potential")
                      : adCoupledNeighborValue("electric_potential")),
    _Phi_e(_electrode ? adCoupledNeighborValue("electric_potential")
                      : adCoupledValue("electric_potential")),
    _U(_electrode ? getADMaterialProperty<Real>("open_circuit_potential")
                  : getNeighborADMaterialProperty<Real>("open_circuit_potential"))
{
}

void
ChargeTransferReaction::computeQpProperties()
{
  // Surface overpotential
  ADReal eta = _Phi_s[_qp] - _Phi_e[_qp] - _U[_qp];

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _alpha * _F / _R / T;
  _i[_qp] = _i0 * (std::exp(coef * eta) - std::exp(-coef * eta));

  // Mass flux
  _j[_qp] = _i[_qp] * _R * _T[_qp] / _F;
}
