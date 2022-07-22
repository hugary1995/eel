#pragma once

#include "ChemicalDissipationDensity.h"

/**
 * This class defines the viscous dissipation in mass transport
 */
class ViscousMassTransport : public ChemicalDissipationDensity
{
public:
  static InputParameters validParams();

  ViscousMassTransport(const InputParameters & parameters);

protected:
  virtual ADReal computeQpChemicalDissipationDensity() const override;
  virtual ADReal computeQpDChemicalDissipationDensityDConcentrationRate() override;
  virtual ADRealVectorValue
  computeQpDChemicalDissipationDensityDConcentrationRateGradient() override;

  /// The concetration
  const ADVariableValue & _c;

  /// Ideal gas constant
  const Real _R;

  /// Temperature
  const ADVariableValue & _T;
};
