#pragma once

#include "ChemicalDissipationDensity.h"

/**
 * Joule heating due to concentration change of charged species
 */
class JouleHeating : public ChemicalDissipationDensity
{
public:
  static InputParameters validParams();

  JouleHeating(const InputParameters & parameters);

protected:
  virtual ADReal computeQpChemicalDissipationDensity() const override;
  virtual ADReal computeQpDChemicalDissipationDensityDConcentrationRate() override;
  virtual ADRealVectorValue
  computeQpDChemicalDissipationDensityDConcentrationRateGradient() override;

  /// The electric field
  const ADVariableGradient & _grad_Phi;

  /// The electric conductivity
  const ADMaterialProperty<Real> & _sigma;

  /// Faraday's constant
  const Real _F;
};
