#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "RankTwoTensorForward.h"

class MassDiffusion : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  MassDiffusion(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Mass flux
  ADMaterialProperty<RealVectorValue> & _j;

  /// The mobility
  const ADMaterialProperty<Real> & _M;

  /// Ideal gas constant
  const Real _R;

  /// Temperature
  const ADVariableValue & _T;

  /// Temperature gradient
  const ADVariableGradient & _grad_T;

  /// Concentration
  const ADVariableValue & _c;

  /// Reference concentration
  const VariableValue & _c0;

  /// Concentration gradient
  const ADVariableGradient & _grad_c;

  /// Gradient of the additional chemical potential
  const ADVariableGradient * _grad_mu;
};
