#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

/**
 * This class computes the electrical energy density and the corresponding thermodynamic forces. In
 * this app, we assume the electrical energy density depends on at least the deformation gradient
 * and the gradient of electrical potential.
 */
class ElectricalEnergyDensity : public DerivativeMaterialInterface<Material>,
                                public BaseNameInterface
{
public:
  static InputParameters validParams();

  ElectricalEnergyDensity(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// Compute the electrical energy density
  virtual ADReal computeQpElectricalEnergyDensity() const = 0;

  /// Compute \frac{\partial \psi^e}{\partial \nabla \Phi}
  virtual ADRealVectorValue computeQpDElectricalEnergyDensityDElectricalPotentialGradient() = 0;

  /// Compute \frac{\partial \psi^e}{\partial F}
  virtual ADRankTwoTensor computeQpDElectricalEnergyDensityDDeformationGradient() = 0;

  /// The gradient of the electrical potential
  const ADVariableGradient & _grad_Phi;

  /// The deformation gradient
  const ADMaterialProperty<RankTwoTensor> * _F;

  /// The name of the electrical potential variable
  const VariableName _Phi_name;

  /// Name of the electrical energy density
  const MaterialPropertyName _psi_name;

  /// The electrical energy density
  ADMaterialProperty<Real> & _psi;

  /// Derivative of the electrical energy density w.r.t. the electrical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_psi_d_grad_Phi;

  /// Derivative of the electrical energy density w.r.t. the deformation gradient
  ADMaterialProperty<RankTwoTensor> * _d_psi_d_F;
};
