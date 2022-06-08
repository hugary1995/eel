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
  /// Name of the concentration variable
  const VariableName _c_name;
};
