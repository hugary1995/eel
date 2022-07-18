#include "Polarization.h"

registerMooseObject("StingrayApp", Polarization);

InputParameters
Polarization::validParams()
{
  InputParameters params = ElectricalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the electrical polarization potential.");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "The electric conductivity");
  return params;
}

Polarization::Polarization(const InputParameters & parameters)
  : ElectricalEnergyDensity(parameters),
    _sigma(getADMaterialPropertyByName<Real>(prependBaseName("electric_conductivity", true)))
{
}

void
Polarization::precomputeQpProperties()
{
  const ADRankTwoTensor F = _F ? (*_F)[_qp] : ADRankTwoTensor::Identity();

  // Pull back the electric conductivity
  _J = F.det();
  _F_inv = F.inverse();
  _sigma_0 = _J * _F_inv * _sigma[_qp] * _F_inv.transpose();
}

ADReal
Polarization::computeQpElectricalEnergyDensity() const
{
  return 0.5 * _grad_Phi[_qp] * (_sigma_0 * _grad_Phi[_qp]);
}

ADRealVectorValue
Polarization::computeQpDElectricalEnergyDensityDElectricalPotentialGradient()
{
  return _sigma_0 * _grad_Phi[_qp];
}

ADRankTwoTensor
Polarization::computeQpDElectricalEnergyDensityDDeformationGradient()
{
  const ADReal psi = computeQpElectricalEnergyDensity();
  const auto exe = ADRankTwoTensor::outerProduct(_grad_Phi[_qp], _sigma_0 * _grad_Phi[_qp]);

  return _F_inv.transpose() * (psi * ADRankTwoTensor::Identity() - exe);
}
