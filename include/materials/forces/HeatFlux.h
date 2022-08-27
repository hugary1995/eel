#pragma once

#include "ThermodynamicForce.h"

class HeatFlux : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  HeatFlux(const InputParameters & parameters);
};
