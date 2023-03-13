#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class SwellingStrain : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  SwellingStrain(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  /// Name of the swelling strain
  const MaterialPropertyName _Es_name;

  /// The swelling strain
  ADMaterialProperty<RankTwoTensor> & _Es;

  /// Names of the concentration variable
  const VariableName _c_name;

  /// Concentration
  const ADVariableValue & _c;

  /// Reference concentration
  const ADVariableValue & _c_ref;

  /// Molar volume
  const Real _Omega;

  /// The swelling coefficient
  const ADMaterialProperty<Real> & _alpha_s;

  // Derivative of the equivalent swelling strain w.r.t. the concentration
  ADMaterialProperty<Real> & _d_es_d_c;
};
