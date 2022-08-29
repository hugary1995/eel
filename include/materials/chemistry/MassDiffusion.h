#pragma once

#include "ChemicalEnergyDensity.h"
#include "RankTwoTensorForward.h"

class MassDiffusion : public ChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  MassDiffusion(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The diffusion coefficient
  const ADMaterialProperty<RankTwoTensor> & _D;

  /// Ideal gas constant
  const Real _R;

  /// Temperature variable
  const MooseVariable * _T_var;

  /// Temperature
  const ADVariableValue & _T;

  /// Derivative of the chemical energy density w.r.t. the log temperature
  ADMaterialProperty<Real> & _d_G_d_lnT;

  /// The deformation gradient, if exists
  const ADMaterialProperty<RankTwoTensor> * _F;
};
