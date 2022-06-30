#pragma once

#include "Material.h"
#include "BaseNameInterface.h"

/**
 * Joule heating due to electric displacement
 */
class JouleHeating : public Material, public BaseNameInterface
{
public:
  static InputParameters validParams();

  JouleHeating(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The joule heating power per unit volume
  ADMaterialProperty<Real> & _q;

  /// The gradient of the electrical potential
  const ADVariableGradient & _grad_Phi;

  /// The electrical conductivity
  const ADMaterialProperty<Real> & _sigma;
};
