#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialPropertyNameInterface.h"

/**
 * This class computes the eigen deformation gradient induced by swelling
 */
class Swelling : public Material,
                 public BaseNameInterface,
                 public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  Swelling(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  virtual void initQpStatefulProperties() override;

  /// The eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fs;

  /// Names of the concentration variables
  std::vector<VariableName> _c_names;

  /// Concentration of each species
  std::vector<const ADVariableValue *> _c;

  /// Reference concentration of each species
  std::vector<const ADVariableValue *> _c_ref;

  /// @{ Molar volume of each species
  std::vector<MaterialPropertyName> _Omega_names;
  std::vector<const ADMaterialProperty<Real> *> _Omega;
  /// @}

  /// Swelling coefficient
  const ADMaterialProperty<Real> & _beta;

  // Derivative of the eigen deformation gradient w.r.t. each concentration variable
  std::vector<ADMaterialProperty<RankTwoTensor> *> _d_Fs_d_c;
};
