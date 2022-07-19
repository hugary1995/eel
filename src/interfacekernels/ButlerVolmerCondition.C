#include "ButlerVolmerCondition.h"

registerMooseObject("StingrayApp", ButlerVolmerCondition);

InputParameters
ButlerVolmerCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription(
      "The Butler-Volmer condition across the electrode/electrolyte interface. Note that the "
      "boundary this interface kernel acts on should be on the elctrode subdomain.");
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
  params.addRequiredParam<Real>("open_circuit_potential", "The open-circuite potential");
  params.addRequiredCoupledVar("electrode_concentration",
                               "Concentration of the charged species in the electrode");
  params.addRequiredCoupledVar("electrolyte_concentration",
                               "Concentration of the charged species in the electrolyte");
  params.addRequiredParam<Real>("maximum_concentration",
                                "Maximum concentration of the charged species in the electrode");
  params.addRequiredParam<Real>("charge_transfer_rate", "The charge transfer rate");
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
    _U(getParam<Real>("open_circuit_potential")),
    _c_s(adCoupledValue("electrode_concentration")),
    _c_e(adCoupledNeighborValue("electrolyte_concentration")),
    _c_max(getParam<Real>("maximum_concentration")),
    _n(getParam<Real>("charge_transfer_rate"))
{
}

ADReal
ButlerVolmerCondition::computeQpResidual(Moose::DGResidualType type)
{
  // Surface overpotential
  ADReal eta = _u[_qp] - _neighbor_value[_qp] - _U;

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _F / _R / T * eta;
  ADReal i = _i0 * (std::exp(_alpha_a * coef) - std::exp(-_alpha_c * coef));

  // Concentration dependent OCV
  i *= std::pow(_c_s[_qp], _n) * std::pow(_c_max - _c_s[_qp], 1 - _n) * std::pow(_c_e[_qp], 1 - _n);

  switch (type)
  {
    case Moose::Element:
      return -_test[_i][_qp] * i;

    case Moose::Neighbor:
      return _test_neighbor[_i][_qp] * i;
  }

  return 0;
}
