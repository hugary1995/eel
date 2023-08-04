// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADInterfaceKernel.h"

class NoPenetration : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  NoPenetration(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real _penalty;

  const unsigned int _component;

  const ADMaterialProperty<RealVectorValue> & _interface_displacement_jump;

  const ADMaterialProperty<RankTwoTensor> & _R;
};
