#pragma once

#include "ADKernel.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class implements the weak form for the divergence of the first Piola-Kirchhoff stress
 */
class StressDivergence : public ADKernel, public BaseNameInterface
{
public:
  static InputParameters validParams();

  StressDivergence(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The first Piola-Kirchhoff stress
  const ADMaterialProperty<RankTwoTensor> & _PK1;

  /// An integer corresponding to the direction this kernel acts in
  const unsigned int _component;
};
