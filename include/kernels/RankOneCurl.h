// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADKernel.h"

class RankOneCurl : public ADKernel
{
public:
  static InputParameters validParams();

  RankOneCurl(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The vector
  const ADMaterialProperty<RealVectorValue> & _vector;

  /// An integer corresponding to the direction this kernel acts in
  const unsigned int _component;

  /// The multiplication factor
  const Real _factor;
};
