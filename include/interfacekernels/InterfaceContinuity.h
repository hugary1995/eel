#pragma once

#include "ADInterfaceKernel.h"

class InterfaceContinuity : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  InterfaceContinuity(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real _penalty;
};
