#include "MassBalanceTimeDerivative.h"

registerMooseObject("StingrayApp", MassBalanceTimeDerivative);

InputParameters
MassBalanceTimeDerivative::validParams()
{
  InputParameters params = ADTimeDerivative::validParams();
  params.addClassDescription(
      "Time derivative term $R T \\frac{\\partial c}{\\partial t}$ of the mass balance equation.");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  return params;
}

MassBalanceTimeDerivative::MassBalanceTimeDerivative(const InputParameters & parameters)
  : ADTimeDerivative(parameters),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature"))
{
}

ADReal
MassBalanceTimeDerivative::precomputeQpResidual()
{
  return -_R * _T[_qp] * ADTimeDerivative::precomputeQpResidual();
}
