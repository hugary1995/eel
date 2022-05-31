#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class computes the eigen deformation gradient induced by swelling
 */
class Swelling : public Material, public BaseNameInterface
{
public:
  static InputParameters validParams();

  Swelling(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  virtual void initQpStatefulProperties() override;

  /// The eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fg;

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
};
