#include "DeformationGradient.h"

registerADMooseObject("StingrayApp", DeformationGradient);

InputParameters
DeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class computes the deformation gradient. Eigen deformation gradients are extracted "
      "from the total deformation gradient. The F-bar approach can optionally be used to correct "
      "volumetric locking.");

  params.addRequiredCoupledVar(
      "displacements",
      "The displacements appropriate for the simulation geometry and coordinate system");
  params.addParam<bool>(
      "volumetric_locking_correction", false, "Flag to correct volumetric locking");
  params.suppressParameter<bool>("use_displaced_mesh");

  return params;
}

DeformationGradient::DeformationGradient(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _disp(adCoupledValues("displacements")),
    _grad_disp(adCoupledGradients("displacements")),
    _volumetric_locking_correction(getParam<bool>("volumetric_locking_correction") &&
                                   !this->isBoundaryMaterial()),
    _current_elem_volume(_assembly.elemVolume()),
    _F(declareADProperty<RankTwoTensor>(prependBaseName("deformation_gradient"))),
    _Fm(declareADProperty<RankTwoTensor>(prependBaseName("mechanical_deformation_gradient"))),
    _Fs(hasADMaterialProperty<RankTwoTensor>(prependBaseName("swelling_deformation_gradient"))
            ? &getADMaterialPropertyByName<RankTwoTensor>(
                  prependBaseName("swelling_deformation_gradient"))
            : nullptr),
    _Ft(hasADMaterialProperty<RankTwoTensor>(prependBaseName("thermal_deformation_gradient"))
            ? &getADMaterialPropertyByName<RankTwoTensor>(
                  prependBaseName("thermal_deformation_gradient"))
            : nullptr),
    _d_Fm_d_F(declareADProperty<RankFourTensor>(
        derivativePropertyName(prependBaseName("mechanical_deformation_gradient"),
                               {prependBaseName("deformation_gradient")}))),
    _d_Fm_d_Fs(_Fs ? &declareADProperty<RankFourTensor>(
                         derivativePropertyName(prependBaseName("mechanical_deformation_gradient"),
                                                {prependBaseName("swelling_deformation_gradient")}))
                   : nullptr)
{
  if (getParam<bool>("use_displaced_mesh"))
    paramError("use_displaced_mesh",
               "Deformation gradient needs to be calculated on the undisplaced mesh.");

  // Set unused components to zero
  _disp.resize(3, &_ad_zero);
  _grad_disp.resize(3, &_ad_grad_zero);
}

void
DeformationGradient::initQpStatefulProperties()
{
  _F[_qp].setToIdentity();
  _Fm[_qp].setToIdentity();
}

void
DeformationGradient::computeProperties()
{
  ADReal ave_F_det = 0;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    _F[_qp] = ADRankTwoTensor::initializeFromRows(
        (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
    _F[_qp].addIa(1.0);

    if (_volumetric_locking_correction)
      ave_F_det += _F[_qp].det() * _JxW[_qp] * _coord[_qp];
  }

  if (_volumetric_locking_correction)
    ave_F_det /= _current_elem_volume;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    if (_volumetric_locking_correction)
      _F[_qp] *= std::cbrt(ave_F_det / _F[_qp].det());

    // Remove the eigen deformation gradients
    _Fm[_qp] = _F[_qp];
    ADRankTwoTensor Fg(ADRankTwoTensor::initIdentity);
    if (_Fs)
      Fg *= (*_Fs)[_qp];
    if (_Ft)
      Fg *= (*_Ft)[_qp];
    _Fm[_qp] *= Fg.inverse();

    // Derivatives
    ADRankTwoTensor I(ADRankTwoTensor::initIdentity);

    usingTensorIndices(i, j, k, l);
    _d_Fm_d_F[_qp] = I.times<i, k, l, j>(Fg.inverse());
    if (_Fs)
      (*_d_Fm_d_Fs)[_qp] = -_Fm[_qp].times<i, k, l, j>((*_Fs)[_qp].inverse());
  }
}
