#pragma once

#include "ElasticEnergyDensityBase.h"

/**
 * This class defines the Neo-Hookean elastic energy density
 */
class NeoHookeanElasticEnergyDensity : public ElasticEnergyDensityBase
{
public:
  static InputParameters validParams();

  NeoHookeanElasticEnergyDensity(const InputParameters & parameters);

protected:
  virtual ADReal computeQpElasticEnergyDensity() const override;

  virtual ADRankTwoTensor computeQpDElasticEnergyDensityDMechanicalDeformationGradient() override;

  /// Lame's first parameter
  const ADMaterialProperty<Real> & _lambda;

  /// Shear modulus
  const ADMaterialProperty<Real> & _G;
};
