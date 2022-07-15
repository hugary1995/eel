#include "ButlerVolmerCondition.h"

registerMooseObject("StingrayApp", ButlerVolmerCondition);

InputParameters
ButlerVolmerCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription(
      "The Butler-Volmer condition across the electrode/electrolyte interface");
  params.addRequiredParam<Real>("exchange_current_density",
                                "The exchange current density (normal to the interface) for the "
                                "electrode/electrolyte interface");
  params.addRequiredParam<Real>("anodic_charge_transfer_coefficient",
                                "The dimensionless anodic charge transfer coefficient");
  params.addRequiredParam<Real>("cathodic_charge_transfer_coefficient",
                                "The dimensionless cathodic charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredParam<Real>("electric_conductivity", "The electric conductivity");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredParam<SubdomainName>("electrode_subdomain",
                                         "The subdomain name of the electrode");
  params.addRequiredParam<SubdomainName>("electrolyte_subdomain",
                                         "The subdomain name of the electrolyte");
  params.addRequiredParam<Real>("open_circuit_potential", "The open-circuite potential");
  return params;
}

ButlerVolmerCondition::ButlerVolmerCondition(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _i0(getParam<Real>("exchange_current_density")),
    _alpha_a(getParam<Real>("anodic_charge_transfer_coefficient")),
    _alpha_c(getParam<Real>("cathodic_charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _sigma(getParam<Real>("electric_conductivity")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _electrode_subdomain_id(_mesh.getSubdomainID(getParam<SubdomainName>("electrode_subdomain"))),
    _electrolyte_subdomain_id(
        _mesh.getSubdomainID(getParam<SubdomainName>("electrolyte_subdomain"))),
    _U(getParam<Real>("open_circuit_potential"))
{
}

ADReal
ButlerVolmerCondition::computeQpResidual(Moose::DGResidualType type)
{
  if (_current_elem->subdomain_id() == _electrolyte_subdomain_id)
    return 0;

  mooseAssert(_current_elem->subdomain_id() == _electrode_subdomain_id,
              "We should be on the electrode here.");

  // Surface overpotential
  ADReal eta = _u[_qp] - _neighbor_value[_qp] - _U;

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _F / _R / T * eta;
  ADReal i = _i0 * (std::exp(_alpha_a * coef) - std::exp(-_alpha_c * coef));

  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * i;

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * i;
  }

  return 0;
}
