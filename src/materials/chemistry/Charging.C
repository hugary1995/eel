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
  params.addRequiredParam<MaterialPropertyName>("viscosity", "The mass transport viscosity");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredParam<Real>("molar_volume", "The molar volume for this species");
  return params;
}

Charging::Charging(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _sigma(getADMaterialPropertyByName<Real>(prependBaseName("electric_conductivity", true))),
    _F(getParam<Real>("faraday_constant")),
    _eta(getADMaterialPropertyByName<Real>(prependBaseName("viscosity", true))),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _Omega(getParam<Real>("molar_volume")),
    _d_psi_d_grad_Phi(declareADProperty<RealVectorValue>(derivativePropertyName(
        prependBaseName(_psi_name), {"grad_" + getVar("electric_potential", 0)->name()})))
{
}

void
Charging ::computeQpProperties()
{
  ChemicalEnergyDensity::computeQpProperties();

  ADReal Xi = _eta[_qp] * _R * _T[_qp] * _Omega;
  _d_psi_d_grad_Phi[_qp] = Xi * _sigma[_qp] / _F * _grad_c[_qp];
}

ADReal
Charging::computeQpChemicalEnergyDensity() const
{
  ADReal Xi = _eta[_qp] * _R * _T[_qp] * _Omega;
  return Xi * _sigma[_qp] / _F * _grad_Phi[_qp] * _grad_c[_qp];
}

ADReal
Charging::computeQpDChemicalEnergyDensityDConcentration()
{
  return 0;
}

ADRealVectorValue
Charging::computeQpDChemicalEnergyDensityDConcentrationGradient()
{
  ADReal Xi = _eta[_qp] * _R * _T[_qp] * _Omega;
  return Xi * _sigma[_qp] / _F * _grad_Phi[_qp];
}

ADRankTwoTensor
Charging::computeQpDChemicalEnergyDensityDDeformationGradient()
{
  ADRankTwoTensor zero;
  return zero;
}