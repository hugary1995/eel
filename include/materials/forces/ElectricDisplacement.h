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
  /// Name of the electric potential
  const VariableName _Phi_name;
};
