#include "Charging.h"

registerMooseObject("StingrayApp", Charging);

InputParameters
Charging::validParams()
{
  InputParameters params = ChemicalEnergyDensity::validParams();
  params.addClassDescription(
      params.getClassDescription() +
      " This class defines the mass transport of a charged species driven by electric potential.");
  params.addRequiredCoupledVar("electric_potential", "The electric potential");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "The electric conductivity");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  return params;
}

Charging::Charging(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _sigma(getADMaterialPropertyByName<Real>(prependBaseName("electric_conductivity", true))),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature"))
{
}

ADReal
Charging::computeQpChemicalEnergyDensity() const
{
  return (_sigma[_qp] * _grad_Phi[_qp]) * (_R * _T[_qp] / _F * _grad_c[_qp] / _c[_qp]);
}

ADReal
Charging::computeQpDChemicalEnergyDensityDConcentration()
{
  return 0;
}

ADRealVectorValue
Charging::computeQpDChemicalEnergyDensityDConcentrationGradient()
{
  return _sigma[_qp] * _R * _T[_qp] / _F * _grad_Phi[_qp];
}

ADRankTwoTensor
Charging::computeQpDChemicalEnergyDensityDDeformationGradient()
{
  ADRankTwoTensor zero;
  return zero;
}
