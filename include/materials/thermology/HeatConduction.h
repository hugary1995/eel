#pragma once

#include "ThermalEnergyDensity.h"
#include "RankTwoTensorForward.h"

class HeatConduction : public ThermalEnergyDensity
{
public:
  static InputParameters validParams();

  HeatConduction(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The thermal conductivity
  const ADMaterialProperty<RankTwoTensor> & _kappa;
};
