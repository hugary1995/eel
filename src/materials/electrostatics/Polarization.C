//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

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
    _F(getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("deformation_gradient"))),
    _eps_0(getADMaterialPropertyByName<Real>(prependBaseName("vacuum_permittivity", true))),
    _eps_r(getADMaterialPropertyByName<Real>(prependBaseName("relative_permittivity", true)))
{
}

ADReal
Polarization::computeQpElectricalEnergyDensity() const
{
  const ADRankTwoTensor F_inv_t = _F[_qp].inverse().transpose();
  const ADRealVectorValue e = F_inv_t * _grad_Phi[_qp];
  const ADReal J = _F[_qp].det();
  return 0.5 * J * _eps_0[_qp] * _eps_r[_qp] * e * e;
}

ADRealVectorValue
Polarization::computeQpDElectricalEnergyDensityDElectricalPotentialGradient()
{
  const ADRankTwoTensor C = _F[_qp].transpose() * _F[_qp];
  const ADReal J = _F[_qp].det();
  return J * _eps_0[_qp] * _eps_r[_qp] * C.inverse() * _grad_Phi[_qp];
}

ADRankTwoTensor
Polarization::computeQpDElectricalEnergyDensityDDeformationGradient()
{
  const ADRankTwoTensor F_inv_t = _F[_qp].inverse().transpose();
  const ADRealVectorValue e = F_inv_t * _grad_Phi[_qp];
  const ADReal J = _F[_qp].det();

  ADRankTwoTensor exe;
  exe.vectorOuterProduct(e, e);
  return J * _eps_0[_qp] * _eps_r[_qp] * (0.5 * e * e * F_inv_t - exe);
}
