#pragma once

#include "ElectroChemicalEnergyDensity.h"

class Migration : public ElectroChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  Migration(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The electric conductivity
  const ADMaterialProperty<Real> & _sigma;

  /// Faraday's constant
  const Real _F;
};
