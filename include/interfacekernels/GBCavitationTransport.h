#pragma once

#include "ADInterfaceKernel.h"

class GBCavitationTransport : public ADInterfaceKernel
{
public:
  static InputParameters validParams();
  GBCavitationTransport(const InputParameters & parameters);

protected:
  ADReal computeQpResidual(Moose::DGResidualType type) override;

  const VariableValue & _u_old;

  const VariableValue & _u_old_neighbor;

  const ADMaterialProperty<Real> & _j;

  const ADMaterialProperty<Real> & _m;
};
