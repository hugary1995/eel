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
    _c_name(_Fs ? getParam<VariableName>("concentration") : ""),
    _d_psi_d_c(_Fs ? &declarePropertyDerivative<Real, true>(_energy_name, _c_name) : nullptr),
    _d_Js_d_c(_Fs ? &getMaterialPropertyDerivative<Real, true>("det(" + _Fs_name + ")", _c_name)
                  : nullptr),

    // thermal expansion
    _Ft(isParamValid("thermal_deformation_gradient")
            ? &getADMaterialProperty<RankTwoTensor>("thermal_deformation_gradient")
            : nullptr)
{
}
