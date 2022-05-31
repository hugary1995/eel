// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class CurrentDensity : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  CurrentDensity(const InputParameters & parameters);
};
