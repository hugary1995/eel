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

  const ADMaterialProperty<RealVectorValue> & _j; // TODO: change j to vector

  const ADMaterialProperty<Real> & _m;
};
