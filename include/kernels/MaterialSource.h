#pragma once

#include "ADKernelValue.h"
#include "BaseNameInterface.h"

class MaterialSource : public ADKernelValue, public BaseNameInterface
{
public:
  static InputParameters validParams();

  MaterialSource(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  const ADMaterialProperty<Real> & _prop;

  const Real _coef;
};
