// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "VectorKernel.h"

class VectorMaterialSource : public VectorKernel
{
public:
  static InputParameters validParams();

  VectorMaterialSource(const InputParameters & params);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

private:
  const MaterialProperty<Real> & _prop_x;
  const MaterialProperty<Real> & _prop_y;
  const MaterialProperty<Real> & _prop_z;

  const Real _coef;
};
