#pragma once

#include "ADInterfaceKernel.h"

class ButlerVolmerCondition : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  ButlerVolmerCondition(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  virtual ADReal
  openCircuitPotential(const Real U0, const ADReal c, const Real c_max, const Real rate) const;

  virtual ADReal computeQpFlux() const = 0;

  virtual ADReal electrodeElectricPotential() const = 0;

  virtual ADReal electrolyteElectricPotential() const = 0;

  virtual ADReal electrodeConcentration() const = 0;

  virtual ADReal electrolyteConcentration() const = 0;

  const Real _i0;

  const Real _alpha;

  const Real _F;
  const Real _R;

  const ADVariableValue & _T;
  const ADVariableValue & _T_neighbor;

  const Real _U;
  const Real _c_s_max;
  const Real _c_e_max;
  const Real _n;
};
