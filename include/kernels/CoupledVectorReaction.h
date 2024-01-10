// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "VectorKernel.h"

class CoupledVectorReaction : public VectorKernel
{
public:
  static InputParameters validParams();

  CoupledVectorReaction(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  const MaterialProperty<Real> & _prop;

  const Real _coef;

  const VectorVariableValue & _v;

  unsigned int _v_num;
};
