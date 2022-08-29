#include "MechanicalEnergyDensity.h"

InputParameters
MechanicalEnergyDensity::validParams()
{
  InputParameters params = ElasticEnergyDensity::validParams();
  params.addClassDescription(
      "This class computes the elastic energy density and its corresponding "
      "thermodynamic forces. We assume the mechanical energy density depends "
      "on the mechanical deformation gradient.");
  params.addRequiredParam<MaterialPropertyName>("mechanical_deformation_gradient",
                                                "Name of the mechanical deformation gradient");
  params.addRequiredParam<MaterialPropertyName>("eigen_deformation_gradient",
                                                "Name of the eigen deformation gradient");
  params.addParam<MaterialPropertyName>("swelling_deformation_gradient",
                                        "Name of the swelling deformation gradient, if present");
  params.addParam<MaterialPropertyName>("thermal_deformation_gradient",
                                        "Name of the thermal deformation gradient, if present");
  params.addParam<VariableName>("concentration", "The chemical concentration name");
  params.addParam<VariableName>("temperature", "The temperature name");
  return params;
}

MechanicalEnergyDensity::MechanicalEnergyDensity(const InputParameters & parameters)
  : ElasticEnergyDensity(parameters),
    _Fm(getADMaterialProperty<RankTwoTensor>("mechanical_deformation_gradient")),
    _Fg(getADMaterialProperty<RankTwoTensor>("eigen_deformation_gradient")),

    // swelling
    _Fs(isParamValid("swelling_deformation_gradient")
            ? &getADMaterialProperty<RankTwoTensor>("swelling_deformation_gradient")
            : nullptr),
    _Fs_name(_Fs ? getParam<MaterialPropertyName>("swelling_deformation_gradient") : ""),
    _lnc_name(_Fs ? "ln(" + getParam<VariableName>("concentration") + ")" : ""),
    _d_psi_dot_d_lnc(
        _Fs ? &declarePropertyDerivative<Real, true>("dot(" + _energy_name + ")", _lnc_name)
            : nullptr),
    _d_Js_d_lnc(_Fs ? &getMaterialPropertyDerivative<Real, true>("det(" + _Fs_name + ")", _lnc_name)
                    : nullptr),

    // thermal expansion
    _Ft(isParamValid("thermal_deformation_gradient")
            ? &getADMaterialProperty<RankTwoTensor>("thermal_deformation_gradient")
            : nullptr),
    _Ft_name(_Ft ? getParam<MaterialPropertyName>("thermal_deformation_gradient") : ""),
    _lnT_name(_Ft ? "ln(" + getParam<VariableName>("temperature") + ")" : ""),
    _d_psi_dot_d_lnT(
        _Ft ? &declarePropertyDerivative<Real, true>("dot(" + _energy_name + ")", _lnT_name)
            : nullptr),
    _d_Jt_d_lnT(_Ft ? &getMaterialPropertyDerivative<Real, true>("det(" + _Ft_name + ")", _lnT_name)
                    : nullptr)
{
}
