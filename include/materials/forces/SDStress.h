#pragma once

#include "ThermodynamicForce.h"

class SDStress : public ThermodynamicForce<RankTwoTensor>
{
public:
  static InputParameters validParams();

  SDStress(const InputParameters & parameters);
};
