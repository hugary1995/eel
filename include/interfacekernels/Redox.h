#pragma once

#include "ADInterfaceKernel.h"

class Redox : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  Redox(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real _i0;

  const Real _alpha_a;
  const Real _alpha_c;

  const Real _F;
  const Real _R;
  const Real _sigma;

  const ADVariableValue & _T;
  const ADVariableValue & _T_neighbor;

  const Real _penalty;

  const SubdomainID _electrode_subdomain_id;
  const SubdomainID _electrolyte_subdomain_id;
};
