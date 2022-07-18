#pragma once

#include "ADIntegratedBC.h"
#include "Function.h"

class CurrentBC : public ADIntegratedBC
{
public:
  CurrentBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _c;

  const Function & _c_env;

  const Real _c_max;

  const Real _current;
};
