#pragma once

#include "ThermodynamicForce.h"

class FirstPiolaKirchhoffStress : public ThermodynamicForce<RankTwoTensor>
{
public:
  static InputParameters validParams();

  FirstPiolaKirchhoffStress(const InputParameters & parameters);
};
