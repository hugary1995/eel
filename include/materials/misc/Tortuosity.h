#pragma once

#include "Material.h"

class Tortuosity : public Material
{
public:
  static InputParameters validParams();

  Tortuosity(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  ADMaterialProperty<Real> & _tau;

  const ADVariableGradient & _grad_u;
  const ADMaterialProperty<RealVectorValue> & _flux_ref;
};
