// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"

class PK1ToPK2 : public Material
{
public:
  static InputParameters validParams();

  PK1ToPK2(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// PK2
  ADMaterialProperty<RankTwoTensor> & _S;

  /// Deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _F;

  /// PK1
  const ADMaterialProperty<RankTwoTensor> & _P;
};
