#pragma once

#include "ElectricalEnergyDensity.h"

/**
 * This class defines the electro-chemical kinetic energy
 */
class ElectrochemicalKinetics : public ElectricalEnergyDensity
{
public:
  static InputParameters validParams();

  ElectrochemicalKinetics(const InputParameters & parameters);

protected:
  virtual ADReal computeQpElectricalEnergyDensity() const override;
  virtual ADReal computeQpDElectricalEnergyDensityDElectricalPotential() override;
  virtual ADRealVectorValue
  computeQpDElectricalEnergyDensityDElectricalPotentialGradient() override;
  virtual ADRankTwoTensor computeQpDElectricalEnergyDensityDDeformationGradient() override;

  const Real _F;

  const Real _z;

  const ADVariableValue & _c_dot;
};
