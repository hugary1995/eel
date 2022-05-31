// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ThermalDeformationGradient.h"

registerADMooseObject("EelApp", ThermalDeformationGradient);

InputParameters
ThermalDeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the thermal deformation gradient.");
  params.addRequiredParam<MaterialPropertyName>("thermal_deformation_gradient",
                                                "Name of the thermal deformation gradient");
  params.addRequiredParam<MaterialPropertyName>("CTE", "The thermal expansion coefficient");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar("reference_temperature",
                               "The reference temperature corresponding to zero thermal expansion");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

ThermalDeformationGradient::ThermalDeformationGradient(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _Ft_name(getParam<MaterialPropertyName>("thermal_deformation_gradient")),
    _Ft(declareADProperty<RankTwoTensor>(_Ft_name)),
    _T_name(getVar("temperature", 0)->name()),
    _T(adCoupledValue("temperature")),
    _T_ref(coupledValue("reference_temperature")),
    _alpha_t(getADMaterialProperty<Real>("CTE")),
    _d_Jt_d_T(declarePropertyDerivative<Real, true>("det(" + _Ft_name + ")", _T_name))
{
}

void
ThermalDeformationGradient::computeQpProperties()
{
  ADReal Jt = 1 + _alpha_t[_qp] * (_T[_qp] - _T_ref[_qp]);
  _Ft[_qp] = std::cbrt(Jt) * ADRankTwoTensor::Identity();
  _d_Jt_d_T[_qp] = _alpha_t[_qp];
}
