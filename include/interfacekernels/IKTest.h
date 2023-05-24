#pragma once

#include "ADInterfaceKernel.h"

class IKTest : public ADInterfaceKernel
{
public:
  static InputParameters validParams();
  IKTest(const InputParameters & parameters);

protected:
  ADReal computeQpResidual(Moose::DGResidualType type) override;
};
