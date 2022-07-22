#pragma once

#include "ButlerVolmerCondition.h"

class ButlerVolmerMassFlux : public ButlerVolmerCondition
{
public:
  static InputParameters validParams();

  ButlerVolmerMassFlux(const InputParameters & parameters);

protected:
  virtual ADReal computeQpFlux() const override;

  virtual ADReal electrodeElectricPotential() const override { return _Phi_s[_qp]; }

  virtual ADReal electrolyteElectricPotential() const override { return _Phi_e[_qp]; }

  virtual ADReal electrodeConcentration() const override { return _u[_qp]; }

  virtual ADReal electrolyteConcentration() const override { return _neighbor_value[_qp]; }

  const ADVariableValue & _Phi_s;
  const ADVariableValue & _Phi_e;
};
