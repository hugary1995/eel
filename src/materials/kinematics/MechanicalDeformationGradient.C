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
    _d_Fm_d_F(declarePropertyDerivative<RankFourTensor, true>(
        getParam<MaterialPropertyName>("mechanical_deformation_gradient"),
        getParam<MaterialPropertyName>("deformation_gradient"))),
    _d_Fm_d_Fs(_Fs ? &declarePropertyDerivative<RankFourTensor, true>(
                         getParam<MaterialPropertyName>("mechanical_deformation_gradient"),
                         getParam<MaterialPropertyName>("swelling_deformation_gradient"))
                   : nullptr),
    _d_Fm_d_Ft(_Ft ? &declarePropertyDerivative<RankFourTensor, true>(
                         getParam<MaterialPropertyName>("mechanical_deformation_gradient"),
                         getParam<MaterialPropertyName>("thermal_deformation_gradient"))
                   : nullptr)
{
}

void
MechanicalDeformationGradient::initQpStatefulProperties()
{
  _Fm[_qp].setToIdentity();
}

void
MechanicalDeformationGradient::computeQpProperties()
{
  DeformationGradient::computeQpProperties();

  const auto I = ADRankTwoTensor::Identity();

  // Remove the eigen deformation gradients
  _Fm[_qp] = _F[_qp];
  ADRankTwoTensor Fg = I;
  if (_Fs)
    Fg *= (*_Fs)[_qp];
  if (_Ft)
    Fg *= (*_Ft)[_qp];
  _Fm[_qp] *= Fg.inverse();

  usingTensorIndices(i, j, k, l);
  _d_Fm_d_F[_qp] = I.times<i, k, l, j>(Fg.inverse());
  if (_Fs)
    (*_d_Fm_d_Fs)[_qp] = -_Fm[_qp].times<i, k, l, j>((*_Fs)[_qp].inverse());
  if (_Fs)
    (*_d_Fm_d_Ft)[_qp] = -_Fm[_qp].times<i, k, l, j>((*_Ft)[_qp].inverse());
}
