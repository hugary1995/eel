#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

/**
 * This class computes the chemical dissipation density and the corresponding thermodynamic forces.
 * In this app, we assume the chemical dissipation density depends on at least the rate of change of
 * the concentrations and their gradients.
 */
class ChemicalDissipationDensity : public DerivativeMaterialInterface<Material>,
                                   public BaseNameInterface
{
public:
  static InputParameters validParams();

  ChemicalDissipationDensity(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// Compute the chemical dissipation density
  virtual ADReal computeQpChemicalDissipationDensity() const = 0;

  /// Compute \frac{\partial \psi^c*}{\partial \dot{c}}
  virtual ADReal computeQpDChemicalDissipationDensityDConcentrationRate() = 0;

  /// Compute \frac{\partial \psi^c}{\partial \nabla c}
  virtual ADRealVectorValue computeQpDChemicalDissipationDensityDConcentrationRateGradient() = 0;

  /// The concentration rate
  const ADVariableValue & _c_dot;

  /// The gradient of the concentration rate
  const ADVariableGradient & _grad_c_dot;

  /// The name of the concentration variable
  const VariableName _c_name;

  /// Name of the chemical dissipation density
  const MaterialPropertyName _psi_dis_name;

  /// The chemical dissipation density
  ADMaterialProperty<Real> & _psi_dis;

  /// Derivative of the chemical dissipation density w.r.t. the concentration rate
  ADMaterialProperty<Real> & _d_psi_dis_d_c_dot;

  /// Derivative of the elastic dissipation density w.r.t. the concentration rate gradient
  ADMaterialProperty<RealVectorValue> & _d_psi_dis_d_grad_c_dot;
};
