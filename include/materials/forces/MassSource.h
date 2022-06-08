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
  /// Name of the concentration variable
  const VariableName _c_name;
};
