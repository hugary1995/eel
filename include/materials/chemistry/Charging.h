#pragma once

#include "ChemicalEnergyDensity.h"

/**
 * Mass transport of a charged species driven by electric potential
 */
class Charging : public ChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  Charging(const InputParameters & parameters);

protected:
  virtual ADReal computeQpChemicalEnergyDensity() const override;
  virtual ADReal computeQpDChemicalEnergyDensityDConcentration() override;
  virtual ADRealVectorValue computeQpDChemicalEnergyDensityDConcentrationGradient() override;
  virtual ADRankTwoTensor computeQpDChemicalEnergyDensityDDeformationGradient() override;

  /// The electric field
  const ADVariableGradient & _grad_Phi;

  /// The electric conductivity
  const ADMaterialProperty<Real> & _sigma;

  /// Faraday's constant
  const Real _F;

  /// Ideal gas constant
  const Real _R;

  /// Temperature
  const ADVariableValue & _T;
};
