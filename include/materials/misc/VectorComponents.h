#pragma once

#include "Material.h"

class VectorComponents : public Material
{
public:
  static InputParameters validParams();

  VectorComponents(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  const MaterialPropertyName _v_name;

  ADMaterialProperty<Real> & _x_comp;
  ADMaterialProperty<Real> & _y_comp;
  ADMaterialProperty<Real> & _z_comp;

  const ADMaterialProperty<RealVectorValue> & _v;
};
