//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "DeformationGradient.h"

registerADMooseObject("stingrayApp", DeformationGradient);

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
  params.addParam<std::vector<MaterialPropertyName>>(
      "eigen_deformation_gradient_names", "List of eigen deformation gradients to be applied");

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
    _Fg_names(getParam<std::vector<MaterialPropertyName>>("eigen_deformation_gradient_names")),
    _Fgs(_Fg_names.size()),
    _Fg(declareADProperty<RankTwoTensor>(prependBaseName("total_eigen_deformation_gradient"))),
    _Fg_inv(declareADProperty<RankTwoTensor>(
        prependBaseName("inverse_total_eigen_deformation_gradient")))
{
  // Set unused components to zero
  _disp.resize(3, &_ad_zero);
  _grad_disp.resize(3, &_ad_grad_zero);

  // Get eigen deformation gradients
  for (unsigned int i = 0; i < _Fgs.size(); ++i)
    _Fgs[i] = &getADMaterialPropertyByName<RankTwoTensor>(prependBaseName(_Fg_names[i]));

  if (getParam<bool>("use_displaced_mesh"))
    paramError("use_displaced_mesh",
               "Deformation gradient needs to be calculated on the undisplaced mesh.");
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

    // Remove the eigen deformation gradient
    _Fg[_qp].setToIdentity();
    for (auto Fgi : _Fgs)
      _Fg[_qp] *= (*Fgi)[_qp];
    _Fg_inv[_qp] = _Fg[_qp].inverse();
    _Fm[_qp] = _F[_qp] * _Fg_inv[_qp];
  }
}
