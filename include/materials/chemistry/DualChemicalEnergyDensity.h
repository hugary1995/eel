#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class DualChemicalEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  DualChemicalEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the dual chemical energy density
  const MaterialPropertyName _energy_name;

  /// The chemical potential variable
  const MooseVariable * _mu_var;

  /// The gradient of the chemical potential
  const ADVariableGradient & _grad_mu;

  /// The dual chemical energy density
  ADMaterialProperty<Real> & _zeta;

  /// Derivative of the dual chemical energy density w.r.t. the chemical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_zeta_d_grad_mu;
};
