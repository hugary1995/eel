#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class ElectricalEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ElectricalEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the electrical energy density
  const MaterialPropertyName _energy_name;

  /// The electrical potential variable
  const MooseVariable * _Phi_var;

  /// The gradient of the electrical potential
  const ADVariableGradient & _grad_Phi;

  /// The electrical energy density
  ADMaterialProperty<Real> & _E;

  /// Derivative of the electrical energy density w.r.t. the electrical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_E_d_grad_Phi;
};
