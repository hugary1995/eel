// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "EmbeddedMaterialUnsignedDistance.h"

class EmbeddedMaterialAnisotropy : public EmbeddedMaterialUnsignedDistance
{
public:
  static InputParameters validParams();

  EmbeddedMaterialAnisotropy(const InputParameters & params);

protected:
  virtual void computeQpProperties() override;

  /// The isotropic material property
  const ADMaterialProperty<Real> & _in;

  /// The anisotropic material property
  ADMaterialProperty<RankTwoTensor> & _out;

  /// Width of the embedding
  const Real _b;
};
