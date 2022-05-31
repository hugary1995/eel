// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermalEnergyDensity.h"
#include "RankTwoTensorForward.h"

class FourierPotential : public ThermalEnergyDensity
{
public:
  static InputParameters validParams();

  FourierPotential(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The thermal conductivity
  const ADMaterialProperty<Real> & _kappa;
};
