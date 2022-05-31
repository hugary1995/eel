// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "SwellingStrain.h"

registerADMooseObject("EelApp", SwellingStrain);

InputParameters
SwellingStrain::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the eigenstrain due to swelling.");
  params.addRequiredParam<MaterialPropertyName>("swelling_strain", "Name of the swelling swelling");
  params.addRequiredCoupledVar("concentration",
                               "The chemical concentration contributing to swelling");
  params.addRequiredCoupledVar("reference_concentration",
                               "The reference concentration at which no swelling occurs");
  params.addRequiredParam<Real>("molar_volume", "The molar volume of the chemical species");
  params.addRequiredParam<MaterialPropertyName>("swelling_coefficient", "The swelling coefficient");

  return params;
}

SwellingStrain::SwellingStrain(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _Es_name(getParam<MaterialPropertyName>("swelling_strain")),
    _Es(declareADPropertyByName<RankTwoTensor>(_Es_name)),
    _c_name(getVar("concentration", 0)->name()),
    _c(adCoupledValue("concentration")),
    _c_ref(adCoupledValue("reference_concentration")),
    _Omega(getParam<Real>("molar_volume")),
    _alpha_s(getADMaterialProperty<Real>("swelling_coefficient")),
    _d_es_d_c(declarePropertyDerivative<Real, true>("vol(" + _Es_name + ")", _c_name))
{
}

void
SwellingStrain::computeQpProperties()
{
  ADReal es = _alpha_s[_qp] * _Omega * (_c[_qp] - _c_ref[_qp]);
  _Es[_qp] = es * ADRankTwoTensor::Identity();
  _d_es_d_c[_qp] = _alpha_s[_qp] * _Omega;
}
