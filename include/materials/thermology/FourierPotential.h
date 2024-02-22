// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermalEnergyDensity.h"
#include "RankTwoTensorForward.h"

template <typename T>
class FourierPotentialTempl : public ThermalEnergyDensity
{
public:
  static InputParameters validParams();

  FourierPotentialTempl(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The thermal conductivity
  const ADMaterialProperty<T> & _kappa;
};

typedef FourierPotentialTempl<Real> FourierPotential;
typedef FourierPotentialTempl<RankTwoTensor> AnisotropicFourierPotential;
