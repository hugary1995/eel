// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class MassFlux : public ThermodynamicForce<RealVectorValue>
{
public:
  static InputParameters validParams();

  MassFlux(const InputParameters & parameters);
};
