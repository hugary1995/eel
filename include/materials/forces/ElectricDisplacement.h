#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the electric displacement associated with given energy densities for a given
 * species.
 */
class ElectricDisplacement : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  ElectricDisplacement(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue rate() const override { return (*_grad_Phi_dot)[_qp]; }

  /// Name of the electric potential
  const VariableName _Phi_name;

  /// Rate of electric potential gradient
  const ADVariableGradient * _grad_Phi_dot;
};
