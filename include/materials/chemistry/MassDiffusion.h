#pragma once

#include "Material.h"
#include "DualChemicalEnergyDensity.h"

class MassDiffusion : public DualChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  MassDiffusion(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The mobility
  const ADMaterialProperty<Real> & _M;
};
