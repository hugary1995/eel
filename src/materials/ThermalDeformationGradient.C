#include "ThermalDeformationGradient.h"

registerADMooseObject("StingrayApp", ThermalDeformationGradient);

InputParameters
ThermalDeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class computes the thermal deformation gradient based on the instantaneous CTE.");

  params.addRequiredParam<MaterialPropertyName>("thermal_deformation_gradient",
                                                "The name of the thermal deformation gradient");
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
    _Ft(declareADProperty<RankTwoTensor>(prependBaseName("thermal_deformation_gradient", true))),
    _Ft_old(getMaterialPropertyOldByName<RankTwoTensor>(
        prependBaseName("thermal_deformation_gradient", true))),
    _alpha(getFunction("CTE")),
    _T(adCoupledValue("temperature")),
    _T_old(coupledValueOld("temperature")),
    _T_ref(coupledValue("reference_temperature")),
    _step_one(declareRestartableData<bool>("step_one", true))
{
}

void
ThermalDeformationGradient::initQpStatefulProperties()
{
  _Ft[_qp].setToIdentity();
}

void
ThermalDeformationGradient::computeQpProperties()
{
  if (_t_step > 1)
    _step_one = false;

  const Real old_temp = _step_one ? _T_ref[_qp] : _T_old[_qp];

  const auto alpha = _alpha.value(_T[_qp]);
  const auto alpha_old = _alpha.value(old_temp);

  _Ft[_qp] = (1 + (alpha + alpha_old) / 2 * (_T[_qp] - old_temp)) * _Ft_old[_qp];
}
