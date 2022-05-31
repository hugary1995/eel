// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADTimeDerivative.h"

class EnergyBalanceTimeDerivative : public ADTimeDerivative
{
public:
  static InputParameters validParams();

  EnergyBalanceTimeDerivative(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  /// Specific heat material property
  const ADMaterialProperty<Real> & _cp;

  /// Density material property
  const ADMaterialProperty<Real> & _rho;
};
