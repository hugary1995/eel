// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "InterfaceMaterial.h"

class ChargeTransferReaction : public InterfaceMaterial
{
public:
  static InputParameters validParams();
  ChargeTransferReaction(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeQpProperties() override;

  ADMaterialProperty<Real> & _i;
  const MaterialProperty<Real> & _i_old;
  ADMaterialProperty<Real> & _j;
  ADMaterialProperty<Real> & _h;

  const Real _i0;
  const Real _alpha;
  const Real _F;
  const Real _R;
  const ADVariableValue & _T;
  const ADVariableValue & _T_neighbor;

  const ADVariableValue & _Phi_s;
  const ADVariableValue & _Phi_e;
  const ADMaterialProperty<Real> & _U;

  const ADMaterialProperty<Real> * _rho;
  const ADMaterialProperty<Real> * _g;
};
