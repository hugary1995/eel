// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "DeformationGradient.h"

registerADMooseObject("EelApp", DeformationGradient);

InputParameters
DeformationGradient::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the deformation gradient. The F-bar approach can "
                             "optionally be used to correct volumetric locking.");
  params.addRequiredParam<MaterialPropertyName>("deformation_gradient",
                                                "Name of the deformation gradient");
  params.addRequiredCoupledVar(
      "displacements",
      "The displacements appropriate for the simulation geometry and coordinate system");
  params.addParam<bool>(
      "volumetric_locking_correction", false, "Flag to correct volumetric locking");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

DeformationGradient::DeformationGradient(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _disp(adCoupledValues("displacements")),
    _grad_disp(adCoupledGradients("displacements")),
    _volumetric_locking_correction(getParam<bool>("volumetric_locking_correction")),
    _current_elem_volume(_assembly.elemVolume()),
    _F_name(getParam<MaterialPropertyName>("deformation_gradient")),
    _F(declareADPropertyByName<RankTwoTensor>(_F_name)),
    _F_old(getMaterialPropertyOldByName<RankTwoTensor>(_F_name)),
    _F_dot(declareADPropertyByName<RankTwoTensor>("dot(" + _F_name + ")"))
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
}

void
DeformationGradient::computeProperties()
{
  const auto I = ADRankTwoTensor::Identity();
  _J_avg = 0;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    _F[_qp] = I + ADRankTwoTensor::initializeFromRows(
                      (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);

    if (_volumetric_locking_correction)
      _J_avg += _F[_qp].det() * _JxW[_qp] * _coord[_qp];
  }

  if (_volumetric_locking_correction)
    _J_avg /= _current_elem_volume;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
    computeQpProperties();
}

void
DeformationGradient::computeQpProperties()
{
  if (_volumetric_locking_correction)
    _F[_qp] *= std::cbrt(_J_avg / _F[_qp].det());

  if (_dt > 0)
    _F_dot[_qp] = (_F[_qp] - _F_old[_qp]) / _dt;
  else
    _F_dot[_qp].zero();
}
