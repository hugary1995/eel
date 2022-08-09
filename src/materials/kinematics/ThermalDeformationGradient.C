#include "ThermalDeformationGradient.h"

registerADMooseObject("StingrayApp", ThermalDeformationGradient);

InputParameters
ThermalDeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class computes the thermal deformation gradient based on the instantaneous CTE.");

  params.addRequiredParam<FunctionName>(
      "CTE", "Function describing the thermal expansion coefficient $\alpha$");
  params.addRequiredCoupledVar("temperature", "The current temperature");
  params.addRequiredCoupledVar("reference_temperature",
                               "The reference temperature corresponding to zero thermal expansion");

  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

ThermalDeformationGradient::ThermalDeformationGradient(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _Ft(declareADProperty<RankTwoTensor>(prependBaseName("thermal_deformation_gradient"))),
    _alpha(getFunction("CTE")),
    _T(adCoupledValue("temperature")),
    _T_ref(coupledValue("reference_temperature"))
{
}

void
ThermalDeformationGradient::computeQpProperties()
{
  _Ft[_qp].setToIdentity();
  _Ft[_qp].addIa(_alpha.value(_T[_qp]) * (_T[_qp] - _T_ref[_qp]));
}
