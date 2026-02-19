// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"

class ElectricDisplacement : public Material
{
public:
  static InputParameters validParams();

  ElectricDisplacement(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  ADMaterialProperty<RealVectorValue> & _D_real;
  ADMaterialProperty<RealVectorValue> & _D_imag;

  const ADVariableGradient & _grad_Phi_real;
  const ADVariableGradient & _grad_Phi_imag;

  const ADMaterialProperty<Real> & _eps_real;
  const ADMaterialProperty<Real> & _eps_imag;
};
