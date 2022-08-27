#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class ChemicalEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ChemicalEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the chemical energy density
  const MaterialPropertyName _energy_name;

  /// The concentration variable
  const MooseVariable * _c_var;

  /// The concentration
  const ADVariableValue & _c;

  /// The gradient of the concentration
  const ADVariableGradient & _grad_c;

  /// The chemical energy density
  ADMaterialProperty<Real> & _G;

  /// Derivative of the chemical energy density w.r.t. the concentration gradient
  ADMaterialProperty<RealVectorValue> & _d_G_d_grad_lnc;
};
