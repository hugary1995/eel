#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class MechanicalStrain : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  MechanicalStrain(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties();

  virtual void computeQpProperties();

  // The total strain
  const ADMaterialProperty<RankTwoTensor> & _E;

  // The swelling strain
  const ADMaterialProperty<RankTwoTensor> * _Es;

  // The thermal strain
  const ADMaterialProperty<RankTwoTensor> * _Et;

  // The mechanical strain (after excluding eigenstrains from the total strain)
  ADMaterialProperty<RankTwoTensor> & _Em;

  /// The total eigenstrain
  ADMaterialProperty<RankTwoTensor> & _Eg;
};
