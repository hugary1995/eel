// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class MassSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  MassSource(const InputParameters & parameters);
};
