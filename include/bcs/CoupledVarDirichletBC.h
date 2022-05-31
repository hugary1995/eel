// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "DirichletBCBase.h"

class CoupledVarDirichletBC : public DirichletBCBase
{
public:
  static InputParameters validParams();

  CoupledVarDirichletBC(const InputParameters & parameters);

protected:
  virtual Real computeQpValue() override;

  const VariableValue & _value;
};
