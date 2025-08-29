// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "InterfaceMaterial.h"

class ChargeTransferReactionDegree : public InterfaceMaterial
{
public:
  static InputParameters validParams();
  ChargeTransferReactionDegree(const InputParameters & parameters);

protected:
  void computeQpProperties() override;
  void initQpStatefulProperties() override;

  ADMaterialProperty<Real> & _r;

  const ADVariableValue & _c;
  const Real _c_min;
  const Real _c_max;

  const ADVariableValue & _c_neigh;
  const Real _c_neigh_min;
  const Real _c_neigh_max;
};
