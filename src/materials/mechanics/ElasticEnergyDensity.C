#include "ElasticEnergyDensity.h"

InputParameters
ElasticEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription("This class computes the elastic energy density and its corresponding "
                             "thermodynamic forces. We assume the elastic energy density depends "
                             "on the deformation gradient.");
  params.addRequiredParam<MaterialPropertyName>("elastic_energy_density",
                                                "Name of the elastic energy density");
  params.addRequiredParam<MaterialPropertyName>("deformation_gradient",
                                                "Name of the deformation gradient");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

ElasticEnergyDensity::ElasticEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("elastic_energy_density")),
    _F_name(getParam<MaterialPropertyName>("deformation_gradient")),
    _F(getADMaterialPropertyByName<RankTwoTensor>(_F_name)),
    _F_dot(getADMaterialPropertyByName<RankTwoTensor>("dot(" + _F_name + ")")),
    _psi_dot(declareADProperty<Real>("dot(" + _energy_name + ")")),
    _d_psi_dot_d_F_dot(declarePropertyDerivative<RankTwoTensor, true>("dot(" + _energy_name + ")",
                                                                      "dot(" + _F_name + ")"))
{
}
