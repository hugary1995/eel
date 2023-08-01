// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADKernel.h"

class MassDiffusionTest : public ADKernel
{
public:
  static InputParameters validParams();

  MassDiffusionTest(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  const ADVariableGradient & _grad_mu;

  const ADMaterialProperty<Real> & _M;
};
