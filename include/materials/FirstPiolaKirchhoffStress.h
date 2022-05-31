#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialPropertyNameInterface.h"

/**
 * This class computes the first Piola-Kirchhoff stress associated with given energy densities.
 */
class FirstPiolaKirchhoffStress : public Material,
                                  public BaseNameInterface,
                                  public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  FirstPiolaKirchhoffStress(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The first Piola-Kirchhoff stress
  ADMaterialProperty<RankTwoTensor> & _PK1;

  /// @{ Energy densities
  std::vector<MaterialPropertyName> _psi_names;
  std::vector<const ADMaterialProperty<RankTwoTensor> *> _d_psi_d_F;
  /// @}
};
