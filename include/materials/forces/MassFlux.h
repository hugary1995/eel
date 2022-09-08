#pragma once

#include "ThermodynamicForce.h"

class MassFlux : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  MassFlux(const InputParameters & parameters);
};
