// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "OverlappingElementConstraint.h"

class Function;

class EmbeddedMaterialConstraint : public OverlappingElementConstraint
{
public:
  static InputParameters validParams();

  EmbeddedMaterialConstraint(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type) override;
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  const Function & _R;
};
