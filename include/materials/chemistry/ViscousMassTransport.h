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

  /// The mass transport viscosity
  const ADMaterialProperty<Real> & _eta;

  /// Ideal gas constant
  const Real _R;

  /// Temperature
  const ADVariableValue & _T;

  /// The molar volume of this species;
  const Real _Omega;
};
