#include "MechanicalDeformationGradient.h"

registerADMooseObject("StingrayApp", MechanicalDeformationGradient);

InputParameters
MechanicalDeformationGradient::validParams()
{
  InputParameters params = DeformationGradient::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " Eigen deformation gradients are extracted "
                             "from the total deformation gradient.");
  params.addRequiredParam<MaterialPropertyName>("mechanical_deformation_gradient",
                                                "Name of the mechanical deformation gradient");
  params.addRequiredParam<MaterialPropertyName>("eigen_deformation_gradient",
                                                "Name of the eigen deformation gradient");
  params.addParam<MaterialPropertyName>("swelling_deformation_gradient",
                                        "Name of the swelling deformation gradient, if applicable");
  params.addParam<MaterialPropertyName>("thermal_deformation_gradient",
                                        "Name of the thermal deformation gradient, if applicable");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

MechanicalDeformationGradient::MechanicalDeformationGradient(const InputParameters & parameters)
  : DeformationGradient(parameters),
    _Fs(isParamValid("swelling_deformation_gradient")
            ? &getADMaterialProperty<RankTwoTensor>("swelling_deformation_gradient")
            : nullptr),
    _Ft(isParamValid("thermal_deformation_gradient")
            ? &getADMaterialProperty<RankTwoTensor>("thermal_deformation_gradient")
            : nullptr),
    _Fm(declareADProperty<RankTwoTensor>("mechanical_deformation_gradient")),
    _Fg(declareADProperty<RankTwoTensor>("eigen_deformation_gradient"))
{
}

void
MechanicalDeformationGradient::initQpStatefulProperties()
{
  DeformationGradient::initQpStatefulProperties();
  _Fm[_qp].setToIdentity();
}

void
MechanicalDeformationGradient::computeQpProperties()
{
  DeformationGradient::computeQpProperties();

  // Remove the eigen deformation gradients
  _Fm[_qp] = _F[_qp];
  _Fg[_qp].setToIdentity();
  if (_Fs)
    _Fg[_qp] *= (*_Fs)[_qp];
  if (_Ft)
    _Fg[_qp] *= (*_Ft)[_qp];
  _Fm[_qp] *= _Fg[_qp].inverse();
}
