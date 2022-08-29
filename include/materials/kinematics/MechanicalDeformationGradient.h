#pragma once

#include "DeformationGradient.h"

class MechanicalDeformationGradient : public DeformationGradient
{
public:
  static InputParameters validParams();

  MechanicalDeformationGradient(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;

  void computeQpProperties() override;

  // The swelling deformation gradients
  const ADMaterialProperty<RankTwoTensor> * _Fs;

  // The thermal deformation gradients
  const ADMaterialProperty<RankTwoTensor> * _Ft;

  // The mechanical deformation gradient (after excluding eigen deformation gradients from the total
  // deformation gradient)
  ADMaterialProperty<RankTwoTensor> & _Fm;

  /// The eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fg;
};
