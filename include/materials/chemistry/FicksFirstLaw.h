#pragma once

#include "ChemicalEnergyDensityBase.h"

/**
 * This class defines the Fick's first law
 */
class FicksFirstLaw : public ChemicalEnergyDensityBase
{
public:
  static InputParameters validParams();

  FicksFirstLaw(const InputParameters & parameters);

protected:
  virtual ADReal computeQpChemicalEnergyDensity() const override;
  virtual ADReal computeQpDChemicalEnergyDensityDConcentration() override;
  virtual ADRealVectorValue computeQpDChemicalEnergyDensityDConcentrationGradient() override;
  virtual ADRankTwoTensor computeQpDChemicalEnergyDensityDDeformationGradient() override;

  /// The diffusion coefficient
  const ADMaterialProperty<RankTwoTensor> & _D;
};
