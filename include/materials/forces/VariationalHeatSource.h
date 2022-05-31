// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class VariationalHeatSource : public ThermodynamicForce<Real>
{
public:
  static InputParameters validParams();

  VariationalHeatSource(const InputParameters & parameters);
};
