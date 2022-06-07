#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

/**
 * This class computes the chemical energy density and the corresponding thermodynamic forces. In
 * this app, we assume the chemical energy density depends on at least the deformation gradient,
 * the concentrations, and the gradients of concentrations.
 */
class ChemicalEnergyDensity : public DerivativeMaterialInterface<Material>, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ChemicalEnergyDensity(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// Compute the chemical energy density
  virtual ADReal computeQpChemicalEnergyDensity() const = 0;

  /// Compute \frac{\partial \psi^c}{\partial c}
  virtual ADReal computeQpDChemicalEnergyDensityDConcentration() = 0;

  /// Compute \frac{\partial \psi^c}{\partial \nabla c}
  virtual ADRealVectorValue computeQpDChemicalEnergyDensityDConcentrationGradient() = 0;

  /// Compute \frac{\partial \psi^c}{\partial F}
  virtual ADRankTwoTensor computeQpDChemicalEnergyDensityDDeformationGradient() = 0;

  /// The concentration
  const ADVariableValue & _c;

  /// The gradient of the concentration
  const ADVariableGradient & _grad_c;

  /// The name of the concentration variable
  const VariableName _c_name;

  /// Name of the chemical energy density
  const MaterialPropertyName _psi_name;

  /// The chemical energy density
  ADMaterialProperty<Real> & _psi;

  /// Derivative of the chemical energy density w.r.t. the concentration
  ADMaterialProperty<Real> & _d_psi_d_c;

  /// Derivative of the chemical energy density w.r.t. the concentration gradient
  ADMaterialProperty<RealVectorValue> & _d_psi_d_grad_c;

  /// Derivative of the chemical energy density w.r.t. the deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_d_F;
};
