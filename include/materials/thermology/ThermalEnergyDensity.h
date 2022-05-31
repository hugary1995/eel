// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class ThermalEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ThermalEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the thermal energy density
  const MaterialPropertyName _energy_name;

  /// The temperature variable
  const MooseVariable * _T_var;

  /// The temperature
  const ADVariableValue & _T;

  /// The gradient of the temperature
  const ADVariableGradient & _grad_T;

  /// The thermal energy density
  ADMaterialProperty<Real> & _H;

  /// Derivative of the thermal energy density w.r.t. the log temperature gradient
  ADMaterialProperty<RealVectorValue> & _d_H_d_grad_lnT;
};
