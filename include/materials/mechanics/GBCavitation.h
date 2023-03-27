#pragma once

#include "ADCZMComputeLocalTractionTotalBase.h"

class GBCavitation : public ADCZMComputeLocalTractionTotalBase
{
public:
  static InputParameters validParams();
  GBCavitation(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;

  void computeInterfaceTraction() override;
};
