#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class SwellingDeformationGradient : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  SwellingDeformationGradient(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Name of the swelling deformation gradient
  const MaterialPropertyName _Fs_name;

  /// The swelling deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fs;

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

  // Derivative of the swelling deformation gradient w.r.t. the log concentration
  ADMaterialProperty<RankTwoTensor> & _d_Fs_d_lnc;
};
