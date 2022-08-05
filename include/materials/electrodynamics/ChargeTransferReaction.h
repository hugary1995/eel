#pragma once

#include "InterfaceMaterial.h"

class ChargeTransferReaction : public InterfaceMaterial
{
public:
  static InputParameters validParams();
  ChargeTransferReaction(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  ADMaterialProperty<Real> & _i;
  ADMaterialProperty<Real> & _j;

  const bool _electrode;

  const Real _i0;

  const Real _alpha;

  const Real _F;
  const Real _R;

  const ADVariableValue & _T;
  const ADVariableValue & _T_neighbor;

  const ADVariableValue & _Phi_s;
  const ADVariableValue & _Phi_e;

  const ADMaterialProperty<Real> & _U;
};
