#include "SwellingDeformationGradient.h"

registerADMooseObject("EelApp", SwellingDeformationGradient);

InputParameters
SwellingDeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the eigen deformation gradient due to swelling.");
  params.addRequiredParam<MaterialPropertyName>("swelling_deformation_gradient",
                                                "Name of the swelling deformation gradient");
  params.addRequiredCoupledVar("concentration",
                               "The chemical concentration contributing to swelling");
  params.addRequiredCoupledVar("reference_concentration",
                               "The reference concentration at which no swelling occurs");
  params.addRequiredParam<Real>("molar_volume", "The molar volume of the chemical species");
  params.addRequiredParam<MaterialPropertyName>("swelling_coefficient", "The swelling coefficient");

  return params;
}

SwellingDeformationGradient::SwellingDeformationGradient(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _Fs_name(getParam<MaterialPropertyName>("swelling_deformation_gradient")),
    _Fs(declareADPropertyByName<RankTwoTensor>(_Fs_name)),
    _c_name(getVar("concentration", 0)->name()),
    _c(adCoupledValue("concentration")),
    _c_ref(adCoupledValue("reference_concentration")),
    _Omega(getParam<Real>("molar_volume")),
    _alpha_s(getADMaterialProperty<Real>("swelling_coefficient")),
    _d_Js_d_c(declarePropertyDerivative<Real, true>("det(" + _Fs_name + ")", _c_name))
{
}

void
SwellingDeformationGradient::computeQpProperties()
{
  ADReal Js = 1 + _alpha_s[_qp] * _Omega * (_c[_qp] - _c_ref[_qp]);
  _Fs[_qp] = std::cbrt(Js) * ADRankTwoTensor::Identity();
  _d_Js_d_c[_qp] = _alpha_s[_qp] * _Omega;
}
