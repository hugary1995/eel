#pragma once

#include "ThermodynamicForce.h"

class MassSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  MassSource(const InputParameters & parameters);
};
