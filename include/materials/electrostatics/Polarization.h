#pragma once

#include "ElectricalEnergyDensity.h"

/**
 * This class defines the polarization potential
 */
class Polarization : public ElectricalEnergyDensity
{
public:
  static InputParameters validParams();

  Polarization(const InputParameters & parameters);

protected:
  virtual ADReal computeQpElectricalEnergyDensity() const override;
  virtual ADRealVectorValue
  computeQpDElectricalEnergyDensityDElectricalPotentialGradient() override;
  virtual ADRankTwoTensor computeQpDElectricalEnergyDensityDDeformationGradient() override;

  /// The vacuum permittivity
  const ADMaterialProperty<Real> & _eps_0;

  /// The spatial relative permittivity
  const ADMaterialProperty<Real> & _eps_r;
};
