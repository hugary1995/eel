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

  /// The chemical concentration variable
  const MooseVariable * _c_var;

  /// The chemical concentration
  const ADVariableValue & _c;

  /// The chemical concentration rate
  const ADVariableValue & _c_dot;

  /// The chemical energy density rate
  ADMaterialProperty<Real> & _psi_dot;

  /// Derivative of the chemical energy density rate w.r.t. the chemical concentration rate
  ADMaterialProperty<Real> & _d_psi_dot_d_c_dot;
};
