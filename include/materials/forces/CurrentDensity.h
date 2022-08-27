#pragma once

#include "ThermodynamicForce.h"

class CurrentDensity : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  CurrentDensity(const InputParameters & parameters);
};
