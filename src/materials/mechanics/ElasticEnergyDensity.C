#include "ElasticEnergyDensity.h"

InputParameters
ElasticEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes the elastic energy density and its corresponding "
                             "thermodynamic forces. We assume the elastic energy density depends "
                             "on at least the deformation gradient and the concentrations.");
  params.addRequiredParam<MaterialPropertyName>("elastic_energy_density",
                                                "Name of the elastic energy density");
  params.addCoupledVar(
      "concentrations",
      "Vector of concentrations of chemical species, each contributing to a portion of the "
      "swelling eigen deformation gradient");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

ElasticEnergyDensity::ElasticEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    // Inputs
    _Fm(getADMaterialPropertyByName<RankTwoTensor>(
        prependBaseName("mechanical_deformation_gradient"))),
    _c_names(coupledNames("concentrations")),
    _d_Fm_d_F(getADMaterialPropertyByName<RankFourTensor>(
        derivativePropertyName(prependBaseName("mechanical_deformation_gradient"),
                               {prependBaseName("deformation_gradient")}))),
    _d_Fm_d_Fs(getDefaultMaterialPropertyByName<RankFourTensor, true>(
        derivativePropertyName(prependBaseName("mechanical_deformation_gradient"),
                               {prependBaseName("swelling_deformation_gradient")}))),
    _d_Fs_d_c(coupledComponents("concentrations")),
    // Outputs
    _psi_name(prependBaseName(getParam<MaterialPropertyName>("elastic_energy_density"))),
    _psi(declareADProperty<Real>(prependBaseName(_psi_name))),
    _d_psi_d_F(declareADProperty<RankTwoTensor>(
        derivativePropertyName(_psi_name, {prependBaseName("deformation_gradient")}))),
    _d_psi_d_Fm(declareADProperty<RankTwoTensor>(
        derivativePropertyName(_psi_name, {prependBaseName("mechanical_deformation_gradient")}))),
    _d_psi_d_c(coupledComponents("concentrations"))
{
  // Get d_Fs_d_c and declare d_psi_d_c
  for (auto i : make_range(_c_names.size()))
  {
    _d_Fs_d_c[i] = &getADMaterialPropertyByName<RankTwoTensor>(
        derivativePropertyName(prependBaseName("swelling_deformation_gradient"), {_c_names[i]}));
    _d_psi_d_c[i] = &declareADProperty<Real>(derivativePropertyName(_psi_name, {_c_names[i]}));
  }
}

void
ElasticEnergyDensity::computeQpProperties()
{
  _d_psi_d_Fm[_qp] = computeQpDElasticEnergyDensityDMechanicalDeformationGradient();
  _d_psi_d_F[_qp] = _d_psi_d_Fm[_qp].initialContraction(_d_Fm_d_F[_qp]);

  ADRankTwoTensor d_psi_d_Fs = _d_psi_d_Fm[_qp].initialContraction(_d_Fm_d_Fs[_qp]);
  for (auto i : make_range(_c_names.size()))
    (*_d_psi_d_c[i])[_qp] = d_psi_d_Fs.doubleContraction((*_d_Fs_d_c[i])[_qp]);

  _psi[_qp] = computeQpElasticEnergyDensity();
}
