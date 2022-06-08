#pragma once

#include "ThermodynamicForce.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class computes the first Piola-Kirchhoff stress associated with given energy densities.
 */
class FirstPiolaKirchhoffStress : public ThermodynamicForce<RankTwoTensor>
{
public:
  static InputParameters validParams();

  FirstPiolaKirchhoffStress(const InputParameters & parameters);

protected:
  virtual ADRankTwoTensor rate() const override { return ((*_F)[_qp] - (*_F_old)[_qp]) / _dt; }

  /// Deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _F;

  /// Deformation gradient at the begining of this time step
  const MaterialProperty<RankTwoTensor> * _F_old;
};
