// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADKernel.h"
#include "ADRankTwoTensorForward.h"

class RankTwoDivergence : public ADKernel
{
public:
  static InputParameters validParams();

  RankTwoDivergence(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The second order tensor
  const ADMaterialProperty<RankTwoTensor> & _tensor;

  /// An integer corresponding to the direction this kernel acts in
  const unsigned int _component;

  /// The multiplication factor
  const Real _factor;
};
