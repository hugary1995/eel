#include "ViscousMassTransport.h"

registerMooseObject("StingrayApp", ViscousMassTransport);

InputParameters
ViscousMassTransport::validParams()
{
  InputParameters params = ChemicalDissipationDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the viscous dissipation in mass transport.");
  params.addRequiredParam<MaterialPropertyName>("viscosity", "The mass transport viscosity");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  return params;
}

ViscousMassTransport::ViscousMassTransport(const InputParameters & parameters)
  : ChemicalDissipationDensity(parameters),
    _c(adCoupledValue("concentration")),
    _eta(getADMaterialPropertyByName<Real>(prependBaseName("viscosity", true))),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature"))
{
}

ADReal
ViscousMassTransport::computeQpChemicalDissipationDensity() const
{
  ADReal Xi = _R * _T[_qp];
  return 0.5 * _eta[_qp] * Xi * _c_dot[_qp] * _c_dot[_qp] / _c[_qp];
}

ADReal
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRate()
{
  ADReal Xi = _R * _T[_qp];
  return _eta[_qp] * Xi * _c_dot[_qp];
}

ADRealVectorValue
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRateGradient()
{
  return ADRealVectorValue(0, 0, 0);
}
