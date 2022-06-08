#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the mass flux associated with given energy densities for a given species.
 */
class MassFlux : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  MassFlux(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue rate() const override { return (*_grad_c_dot)[_qp]; }

  /// Name of the concentration variable
  const VariableName _c_name;

  /// Rate of concentration gradient
  const ADVariableGradient * _grad_c_dot;
};
