// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADInterfaceKernel.h"

class InterfaceADMaterialPropertyValue : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  InterfaceADMaterialPropertyValue(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const ADMaterialProperty<Real> & _prop;
};
