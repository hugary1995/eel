#pragma once

#include "ADKernel.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class implements the weak form for the divergence of a second order tensor
 */
class RankTwoDivergence : public ADKernel, public BaseNameInterface
{
public:
  static InputParameters validParams();

  RankTwoDivergence(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The second order tensor
  const ADMaterialProperty<RankTwoTensor> & _tensor;

  /// An integer corresponding to the direction this kernel acts in
  const unsigned int _component;
};
