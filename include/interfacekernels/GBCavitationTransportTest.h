#pragma once

#include "ADInterfaceKernel.h"

class GBCavitationTransportTest : public ADInterfaceKernel
{
public:
  static InputParameters validParams();
  GBCavitationTransportTest(const InputParameters & parameters);

protected:
  ADReal computeQpResidual(Moose::DGResidualType type) override;

  const VariableValue & _u_old;

  const VariableValue & _u_old_neighbor;

  const ADMaterialProperty<Real> & _M;

  const ADVariableGradient & _grad_mu;

  const ADMaterialProperty<Real> & _m;

  const Real _w;
};
