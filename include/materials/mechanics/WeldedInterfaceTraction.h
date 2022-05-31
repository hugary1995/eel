// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADCZMComputeLocalTractionTotalBase.h"

class WeldedInterfaceTraction : public ADCZMComputeLocalTractionTotalBase
{
public:
  static InputParameters validParams();
  WeldedInterfaceTraction(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeInterfaceTraction() override;

  ADMaterialProperty<Real> & _phi_max;
  const MaterialProperty<Real> & _phi_max_old;
  const ADMaterialProperty<Real> & _phi;

  const ADMaterialProperty<Real> & _E;
  const ADMaterialProperty<Real> & _G;

  const Real _eps;
};
