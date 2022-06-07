#pragma once

#include "ThermodynamicForce.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class computes the first Piola-Kirchhoff stress associated with given energy densities.
 */
class FirstPiolaKirchhoffStress : public ThermodynamicForce
{
public:
  static InputParameters validParams();

  FirstPiolaKirchhoffStress(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The first Piola-Kirchhoff stress
  ADMaterialProperty<RankTwoTensor> & _PK1;

  /// Energy densities
  std::vector<const ADMaterialProperty<RankTwoTensor> *> _d_psi_d_F;
};
