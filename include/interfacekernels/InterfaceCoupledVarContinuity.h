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
