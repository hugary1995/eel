#pragma once

#include "ADKernelValue.h"
#include "DerivativeMaterialInterface.h"

class PrimalDualProjection : public DerivativeMaterialInterface<ADKernelValue>
{
public:
  static InputParameters validParams();

  PrimalDualProjection(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual();

  const std::vector<MaterialPropertyName> _psi_names;

  std::vector<const ADMaterialProperty<Real> *> _d_psi_d_s;

  const VariableName _s_name;

  const ADVariableValue & _v;
};
