#include "ButlerVolmerCondition.h"

InputParameters
ButlerVolmerCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<Real>("exchange_current_density",
                                "The exchange current density (normal to the interface) for the "
                                "electrode/electrolyte interface");
  params.addRequiredParam<Real>("charge_transfer_coefficient",
                                "The dimensionless charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addParam<Real>("open_circuit_potential", 0, "The open-circuite potential");
  params.addParam<Real>("maximum_electrode_concentration",
                        1,
                        "Maximum concentration of the charged species in the electrode");
  params.addParam<Real>("maximum_electrolyte_concentration",
                        1,
                        "Maximum concentration of the charged species in the electrolyte");
  params.addParam<Real>("charge_transfer_rate", 0, "The charge transfer rate");
  return params;
}

ButlerVolmerCondition::ButlerVolmerCondition(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _i0(getParam<Real>("exchange_current_density")),
    _alpha(getParam<Real>("charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _U(getParam<Real>("open_circuit_potential")),
    _c_s_max(getParam<Real>("maximum_electrode_concentration")),
    _c_e_max(getParam<Real>("maximum_electrolyte_concentration")),
    _n(getParam<Real>("charge_transfer_rate"))
{
}

ADReal
ButlerVolmerCondition::openCircuitPotential(const Real U0,
                                            const ADReal c,
                                            const Real c_max,
                                            const Real rate) const
{
  return -rate * std::log(c / c_max) * U0;
}

ADReal
ButlerVolmerCondition::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = computeQpFlux();

  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * r;

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * r;
  }

  return 0;
}