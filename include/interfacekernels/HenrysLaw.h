#pragma once

#include "ADInterfaceKernel.h"

class HenrysLaw : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  HenrysLaw(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real _H;

  const Real _penalty;

  const SubdomainID _from_subdomain_id;
  const SubdomainID _to_subdomain_id;
};
