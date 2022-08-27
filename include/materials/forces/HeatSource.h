#pragma once

#include "ThermodynamicForce.h"

class HeatSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  HeatSource(const InputParameters & parameters);
};
