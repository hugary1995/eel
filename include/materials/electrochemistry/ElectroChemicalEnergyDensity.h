#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class ElectroChemicalEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ElectroChemicalEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the electrochemical energy density
  const MaterialPropertyName _energy_name;

  /// The electric potential variable
  const MooseVariable * _Phi_var;

  /// The gradient of the electrical potential
  const ADVariableGradient & _grad_Phi;

  /// The chemical potential variable
  const MaterialPropertyName _mu_name;

  /// The gradient of the chemical potential
  const ADMaterialProperty<RealVectorValue> & _grad_mu;

  /// The electrochemical energy density
  ADMaterialProperty<Real> & _E;

  /// Derivative of the electrochemical energy density w.r.t. the electrical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_E_d_grad_Phi;

  /// Derivative of the electrochemical energy density w.r.t. the electrical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_E_d_grad_mu;
};
