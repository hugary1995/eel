#pragma once

#include "ElasticEnergyDensity.h"

class MechanicalEnergyDensity : public ElasticEnergyDensity
{
public:
  static InputParameters validParams();

  MechanicalEnergyDensity(const InputParameters & parameters);

protected:
  /// Mechanical deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fm;

  /// Eigen deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fg;

  /// Swelling deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _Fs;

  /// Swelling deformation gradient name
  const MaterialPropertyName _Fs_name;

  /// Name of log concentration
  const VariableName _c_name;

  /// Derivative of psi w.r.t. concentration
  ADMaterialProperty<Real> * _d_psi_d_c;

  /// Derivative of Js w.r.t. concentration
  const ADMaterialProperty<Real> * _d_Js_d_c;

  /// Thermal deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _Ft;
};
