// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "ChemicalEnergyDensity.h"

class EntropicChemicalEnergyDensity : public ChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  EntropicChemicalEnergyDensity(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The ideal gas constant
  const Real _R;

  /// The temperature
  const ADVariableValue & _T;

  /// The reference concentration
  const VariableValue & _c0;

  const ADMaterialProperty<Real> & _mu0;
};
