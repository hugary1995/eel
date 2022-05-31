// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "Strain.h"

registerADMooseObject("EelApp", Strain);

InputParameters
Strain::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes the total strain. The F-bar approach can "
                             "optionally be used to correct volumetric locking.");
  params.addRequiredParam<MaterialPropertyName>("strain", "Name of the total strain");
  params.addRequiredCoupledVar(
      "displacements",
      "The displacements appropriate for the simulation geometry and coordinate system");
  params.addParam<bool>(
      "volumetric_locking_correction", false, "Flag to correct volumetric locking");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

Strain::Strain(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _disp(adCoupledValues("displacements")),
    _grad_disp(adCoupledGradients("displacements")),
    _volumetric_locking_correction(getParam<bool>("volumetric_locking_correction")),
    _current_elem_volume(_assembly.elemVolume()),
    _E_name(getParam<MaterialPropertyName>("strain")),
    _E(declareADPropertyByName<RankTwoTensor>(_E_name)),
    _E_old(getMaterialPropertyOldByName<RankTwoTensor>(_E_name)),
    _E_dot(declareADPropertyByName<RankTwoTensor>("dot(" + _E_name + ")"))
{
  if (getParam<bool>("use_displaced_mesh"))
    paramError("use_displaced_mesh",
               "Deformation gradient needs to be calculated on the undisplaced mesh.");

  // Set unused components to zero
  _disp.resize(3, &_ad_zero);
  _grad_disp.resize(3, &_ad_grad_zero);
}

void
Strain::initQpStatefulProperties()
{
  _E[_qp].zero();
}

void
Strain::computeProperties()
{
  _E_tr_avg = 0;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    const auto H = ADRankTwoTensor ::initializeFromRows(
        (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
    _E[_qp] = (H + H.transpose()) / 2.0;

    if (_volumetric_locking_correction)
      _E_tr_avg += _E[_qp].trace() * _JxW[_qp] * _coord[_qp];
  }

  if (_volumetric_locking_correction)
    _E_tr_avg /= _current_elem_volume;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
    computeQpProperties();
}

void
Strain::computeQpProperties()
{
  if (_volumetric_locking_correction)
    _E[_qp].addIa((_E_tr_avg - _E[_qp].trace()) / 3.0);

  _E_dot[_qp] = (_E[_qp] - _E_old[_qp]) / _dt;
}
