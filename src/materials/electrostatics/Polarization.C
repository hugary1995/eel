#include "Polarization.h"

registerMooseObject("StingrayApp", Polarization);

InputParameters
Polarization::validParams()
{
  InputParameters params = ElectricalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the electrical polarization potential.");
  params.addRequiredParam<MaterialPropertyName>("vacuum_permittivity", "The vacuum permittivity");
  params.addRequiredParam<MaterialPropertyName>("relative_permittivity",
                                                "The spatial relative permittivity");
  return params;
}

Polarization::Polarization(const InputParameters & parameters)
  : ElectricalEnergyDensity(parameters),
    _eps_0(getADMaterialPropertyByName<Real>(prependBaseName("vacuum_permittivity", true))),
    _eps_r(getADMaterialPropertyByName<Real>(prependBaseName("relative_permittivity", true)))
{
}

ADReal
Polarization::computeQpElectricalEnergyDensity() const
{
  const ADRankTwoTensor F = _F ? (*_F)[_qp] : ADRankTwoTensor::Identity();
  const ADRankTwoTensor F_inv_t = F.inverse().transpose();
  const ADRealVectorValue e = F_inv_t * _grad_Phi[_qp];
  const ADReal J = F.det();
  return 0.5 * J * _eps_0[_qp] * _eps_r[_qp] * e * e;
}

ADRealVectorValue
Polarization::computeQpDElectricalEnergyDensityDElectricalPotentialGradient()
{
  const ADRankTwoTensor F = _F ? (*_F)[_qp] : ADRankTwoTensor::Identity();
  const ADRankTwoTensor C = F.transpose() * F;
  const ADReal J = F.det();
  return J * _eps_0[_qp] * _eps_r[_qp] * C.inverse() * _grad_Phi[_qp];
}

ADRankTwoTensor
Polarization::computeQpDElectricalEnergyDensityDDeformationGradient()
{
  const ADRankTwoTensor F = (*_F)[_qp];
  const ADRankTwoTensor F_inv_t = F.inverse().transpose();
  const ADRealVectorValue e = F_inv_t * _grad_Phi[_qp];
  const ADReal J = F.det();

  ADRankTwoTensor exe;
  exe.vectorOuterProduct(e, e);
  return J * _eps_0[_qp] * _eps_r[_qp] * (0.5 * e * e * F_inv_t - exe);
}
