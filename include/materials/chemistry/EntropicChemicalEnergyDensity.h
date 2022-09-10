#pragma once

#include "Material.h"
#include "ChemicalEnergyDensity.h"

class EntropicChemicalEnergyDensity : public ChemicalEnergyDensity
{
public:
  static InputParameters validParams();

  EntropicChemicalEnergyDensity(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The ideal gas constant
  const Real _R;

  /// The temperature
  const ADVariableValue & _T;

  /// The reference concentration
  const VariableValue & _c0;

  const bool _condensation;
  ADMaterialProperty<Real> * _d_2_psi_dot_d_c_dot_d_c;
  ADMaterialProperty<Real> * _d_2_psi_dot_d_c_dot_d_T;
};
