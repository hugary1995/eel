// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "InterfaceContinuity.h"

class InterfaceCoupledVarContinuity : public InterfaceContinuity
{
public:
  static InputParameters validParams();

  InterfaceCoupledVarContinuity(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const ADVariableValue & _v;

  const ADVariableValue & _v_neighbor;
};
