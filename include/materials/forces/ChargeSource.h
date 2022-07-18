#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the charge source associated with given energy densities for a given
 * species.
 */
class ChargeSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  ChargeSource(const InputParameters & parameters);

protected:
  virtual ADReal rate() const override { return (*_Phi_dot)[_qp]; }

  /// Name of the electric potential
  const VariableName _Phi_name;

  /// Rate of electric potential gradient
  const ADVariableValue * _Phi_dot;
};
