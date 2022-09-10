#pragma once

#include "MechanicalEnergyDensity.h"

class NeoHookeanSolid : public MechanicalEnergyDensity
{
public:
  static InputParameters validParams();

  NeoHookeanSolid(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Lame's first parameter
  const ADMaterialProperty<Real> & _lambda;

  /// Shear modulus
  const ADMaterialProperty<Real> & _G;

  const bool _condensation;
  ADMaterialProperty<Real> * _d_2_psi_dot_d_c_dot_d_c;
  ADMaterialProperty<Real> * _d_2_psi_dot_d_c_dot_d_T;
  const ADMaterialProperty<Real> * _d_Jt_d_T;
};
