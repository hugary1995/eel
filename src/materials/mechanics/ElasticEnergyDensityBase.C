//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ElasticEnergyDensityBase.h"

InputParameters
ElasticEnergyDensityBase::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes the elastic energy density and its corresponding "
                             "thermodynamic forces. We assume the elastic energy density depends "
                             "on at least the deformation gradient and the concentrations.");

  params.addRequiredParam<MaterialPropertyName>("elastic_energy_density",
                                                "Name of the elastic energy density");

  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

ElasticEnergyDensityBase::ElasticEnergyDensityBase(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _Fg_inv(getADMaterialPropertyByName<RankTwoTensor>(
        prependBaseName("inverse_total_eigen_deformation_gradient"))),
    _Fm(getADMaterialPropertyByName<RankTwoTensor>(
        prependBaseName("mechanical_deformation_gradient"))),
    _psi_name(getParam<MaterialPropertyName>("elastic_energy_density")),
    _psi(declareADProperty<Real>(prependBaseName(_psi_name))),
    _d_psi_d_F(declareADProperty<RankTwoTensor>(derivativePropertyName(
        prependBaseName(_psi_name), {prependBaseName("deformation_gradient")}))),
    _d_psi_d_Fm(declareADProperty<RankTwoTensor>(derivativePropertyName(
        prependBaseName(_psi_name), {prependBaseName("mechanical_deformation_gradient")})))
{
}

void
ElasticEnergyDensityBase::computeQpProperties()
{
  _d_psi_d_Fm[_qp] = computeQpDElasticEnergyDensityDMechanicalDeformationGradient();
  _d_psi_d_F[_qp] = _d_psi_d_Fm[_qp] * _Fg_inv[_qp].transpose();
  _psi[_qp] = computeQpElasticEnergyDensity();
}
