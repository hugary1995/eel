#pragma once

#include "ADTimeDerivative.h"

class MassBalanceTimeDerivative : public ADTimeDerivative
{
public:
  static InputParameters validParams();

  MassBalanceTimeDerivative(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  /// Ideal gas constant
  const Real _R;

  /// Temperature
  const ADVariableValue & _T;
};
