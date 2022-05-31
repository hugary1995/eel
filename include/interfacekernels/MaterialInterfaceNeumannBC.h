// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADInterfaceKernel.h"

class MaterialInterfaceNeumannBC : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  MaterialInterfaceNeumannBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const ADMaterialProperty<Real> & _mat_prop;

  const Real _factor;
  const Real _factor_neighbor;
};
