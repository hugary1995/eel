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
  params.addRequiredParam<Real>("molar_volume", "The molar volume for this species");
  return params;
}

ViscousMassTransport::ViscousMassTransport(const InputParameters & parameters)
  : ChemicalDissipationDensity(parameters),
    _eta(getADMaterialPropertyByName<Real>(prependBaseName("viscosity", true))),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _Omega(getParam<Real>("molar_volume"))
{
}

ADReal
ViscousMassTransport::computeQpChemicalDissipationDensity() const
{
  ADReal Xi = _eta[_qp] * _R * _T[_qp] * _Omega;
  return 0.5 * Xi * _c_dot[_qp] * _c_dot[_qp];
}

ADReal
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRate()
{
  ADReal Xi = _eta[_qp] * _R * _T[_qp] * _Omega;
  return Xi * _c_dot[_qp];
}

ADRealVectorValue
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRateGradient()
{
  return ADRealVectorValue(0, 0, 0);
}
