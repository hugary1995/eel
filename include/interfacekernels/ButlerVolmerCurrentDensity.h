#pragma once

#include "ButlerVolmerCondition.h"

class ButlerVolmerCurrentDensity : public ButlerVolmerCondition
{
public:
  static InputParameters validParams();

  ButlerVolmerCurrentDensity(const InputParameters & parameters);

protected:
  virtual ADReal computeQpFlux() const override;

  virtual ADReal electrodeElectricPotential() const override { return _u[_qp]; }

  virtual ADReal electrolyteElectricPotential() const override { return _neighbor_value[_qp]; }

  virtual ADReal electrodeConcentration() const override { return (*_c_s)[_qp]; }

  virtual ADReal electrolyteConcentration() const override { return (*_c_e)[_qp]; }

  const ADVariableValue * _c_s;
  const ADVariableValue * _c_e;
};
