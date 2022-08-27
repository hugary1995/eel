#pragma once

#include "ElectricalEnergyDensity.h"

class BulkChargeTransport : public ElectricalEnergyDensity
{
public:
  static InputParameters validParams();

  BulkChargeTransport(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The electric conductivity
  const ADMaterialProperty<RankTwoTensor> & _sigma;

  /// The derivative of the electrical energy density w.r.t. the log temperature
  ADMaterialProperty<Real> & _d_E_d_lnT;
};
