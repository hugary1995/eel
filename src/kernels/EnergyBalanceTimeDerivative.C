#include "EnergyBalanceTimeDerivative.h"

registerMooseObject("StingrayApp", EnergyBalanceTimeDerivative);

InputParameters
EnergyBalanceTimeDerivative::validParams()
{
  InputParameters params = ADTimeDerivative::validParams();
  params.addClassDescription(
      "Time derivative term $\\rho c_p \\frac{\\partial T}{\\partial t}$ of the heat equation.");
  params.addRequiredParam<MaterialPropertyName>(
      "specific_heat", "Property name of the specific heat material property");
  params.addRequiredParam<MaterialPropertyName>("density",
                                                "Property name of the density material property");
  return params;
}

EnergyBalanceTimeDerivative::EnergyBalanceTimeDerivative(const InputParameters & parameters)
  : ADTimeDerivative(parameters),
    _cp(getADMaterialProperty<Real>("specific_heat")),
    _rho(getADMaterialProperty<Real>("density"))
{
}

ADReal
EnergyBalanceTimeDerivative::precomputeQpResidual()
{
  return -_rho[_qp] * _cp[_qp] * ADTimeDerivative::precomputeQpResidual();
}
