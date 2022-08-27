#pragma once

#include "ElasticEnergyDensity.h"

class MechanicalEnergyDensity : public ElasticEnergyDensity
{
public:
  static InputParameters validParams();

  MechanicalEnergyDensity(const InputParameters & parameters);

protected:
  /// Mechanical deformation gradient name
  const MaterialPropertyName _Fm_name;

  /// Mechanical deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fm;

  /// Derivative of Fm w.r.t. F
  const ADMaterialProperty<RankFourTensor> & _d_Fm_d_F;

  /// Swelling deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _Fs;

  /// Swelling deformation gradient name
  const MaterialPropertyName _Fs_name;

  /// Name of log concentration
  const VariableName _lnc_name;

  /// Derivative of dot(psi) w.r.t. lnc
  ADMaterialProperty<Real> * _d_psi_dot_d_lnc;

  /// Derivative of Fm w.r.t. Fs
  const ADMaterialProperty<RankFourTensor> * _d_Fm_d_Fs;

  /// Derivative of Fs w.r.t. log concentration
  const ADMaterialProperty<RankTwoTensor> * _d_Fs_d_lnc;

  /// Thermal deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _Ft;

  /// Thermal deformation gradient name
  const MaterialPropertyName _Ft_name;

  /// Name of log temperature
  const VariableName _lnT_name;

  /// Derivative of dot(psi) w.r.t. lnT
  ADMaterialProperty<Real> * _d_psi_dot_d_lnT;

  /// Derivative of Fm w.r.t. Ft
  const ADMaterialProperty<RankFourTensor> * _d_Fm_d_Ft;

  /// Derivative of Ft w.r.t. lnT
  const ADMaterialProperty<RankTwoTensor> * _d_Ft_d_lnT;
};
