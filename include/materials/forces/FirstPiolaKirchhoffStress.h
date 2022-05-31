// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ThermodynamicForce.h"

class FirstPiolaKirchhoffStress : public ThermodynamicForce<RankTwoTensor>
{
public:
  static InputParameters validParams();

  FirstPiolaKirchhoffStress(const InputParameters & parameters);
};
