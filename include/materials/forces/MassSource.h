#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the mass source associated with given energy densities for a given species.
 */
class MassSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  MassSource(const InputParameters & parameters);

protected:
  virtual ADReal rate() const override { return (*_c_dot)[_qp]; }

  /// Name of the concentration variable
  const VariableName _c_name;

  /// Rate of concentration change
  const ADVariableValue * _c_dot;
};
