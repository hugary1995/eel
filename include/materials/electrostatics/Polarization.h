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
  virtual void precomputeQpProperties() override;
  virtual ADReal computeQpElectricalEnergyDensity() const override;
  virtual ADRealVectorValue
  computeQpDElectricalEnergyDensityDElectricalPotentialGradient() override;
  virtual ADRankTwoTensor computeQpDElectricalEnergyDensityDDeformationGradient() override;

  /// The electric conductivity
  const ADMaterialProperty<Real> & _sigma;

private:
  ADReal _J;
  ADRankTwoTensor _F_inv;
  ADRankTwoTensor _sigma_0;
};
