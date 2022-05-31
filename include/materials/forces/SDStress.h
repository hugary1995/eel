// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class SDStress : public ThermodynamicForce<RankTwoTensor>
{
public:
  static InputParameters validParams();

  SDStress(const InputParameters & parameters);
};
