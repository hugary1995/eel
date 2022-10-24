#include "CauchyStress.h"

registerADMooseObject("EelApp", CauchyStress);

InputParameters
CauchyStress::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the Cauchy stress given the PK1 stress");
  params.addRequiredParam<MaterialPropertyName>("cauchy_stress", "Name of the cauchy stress");
  params.addRequiredParam<MaterialPropertyName>("first_piola_kirchhoff_stress",
                                                "Name of the first Piola-Kirchhoff stress");
  params.addRequiredParam<MaterialPropertyName>("deformation_gradient", "The deformation gradient");
  return params;
}

CauchyStress::CauchyStress(const InputParameters & parameters)
  : Material(parameters),
    _cauchy(declareADProperty<RankTwoTensor>("cauchy_stress")),
    _pk1(getADMaterialProperty<RankTwoTensor>("first_piola_kirchhoff_stress")),
    _F(getADMaterialProperty<RankTwoTensor>("deformation_gradient"))
{
}

void
CauchyStress::computeQpProperties()
{
  _cauchy[_qp] = _pk1[_qp] * _F[_qp].transpose() / _F[_qp].det();
}
