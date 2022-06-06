#pragma once

#include "ADKernel.h"
#include "BaseNameInterface.h"

/**
 * This class implements the weak form for the divergence of a vector
 */
class RankOneDivergence : public ADKernel, public BaseNameInterface
{
public:
  static InputParameters validParams();

  RankOneDivergence(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The vector
  const ADMaterialProperty<RealVectorValue> & _vector;
};
