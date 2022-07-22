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
  params.addRequiredParam<SubdomainName>("electrode_subdomain", "The electrode subdomain");
  params.addRequiredParam<Real>("exchange_current_density",
                                "The exchange current density (normal to the interface) for the "
                                "electrode/electrolyte interface");
  params.addRequiredParam<Real>("charge_transfer_coefficient",
                                "The dimensionless charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar("electrode_electric_potential",
                               "Electric potential in the electrode");
  params.addRequiredCoupledVar("electrolyte_electric_potential",
                               "Electric potential in the electrolyte");
  params.addRequiredParam<MaterialPropertyName>("open_circuit_potential",
                                                "The open-circuit potential");
  return params;
}

ChargeTransferReaction::ChargeTransferReaction(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    _i(declareADProperty<Real>(getParam<MaterialPropertyName>("charge_transfer_current_density"))),
    _j(declareADProperty<Real>(getParam<MaterialPropertyName>("charge_transfer_mass_flux"))),
    _electrode_subdomain(_mesh.getSubdomainID(getParam<SubdomainName>("electrode_subdomain"))),
    _i0(getParam<Real>("exchange_current_density")),
    _alpha(getParam<Real>("charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _Phi_s(adCoupledValue("electrode_electric_potential")),
    _Phi_e(adCoupledNeighborValue("electrolyte_electric_potential")),
    _U(getADMaterialProperty<Real>("open_circuit_potential"))
{
}

void
ChargeTransferReaction::computeQpProperties()
{
  if (_current_elem->subdomain_id() != _electrode_subdomain)
    return;

  // Surface overpotential
  ADReal eta = _Phi_s[_qp] - _Phi_e[_qp] - _U[_qp];

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _alpha * _F / _R / T;
  _i[_qp] = _i0 * (std::exp(coef * eta) - std::exp(-coef * eta));

  // Mass flux
  _j[_qp] = _i[_qp] * _R * _T[_qp] / _F;
}
