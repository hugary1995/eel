#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"

/**
 * This class computes the deformation gradient
 */
class DeformationGradient : public Material, public BaseNameInterface
{
public:
  static InputParameters validParams();

  DeformationGradient(const InputParameters & parameters);

  virtual void computeProperties() override;

protected:
  virtual void initQpStatefulProperties() override;

  /// Displacement variables
  std::vector<const ADVariableValue *> _disp;

  /// Gradient of displacements
  std::vector<const ADVariableGradient *> _grad_disp;

  /// Whether to apply volumetric locaking correction
  const bool _volumetric_locking_correction;

  /// The current element volume
  const Real & _current_elem_volume;

  /// The total deformation gradient
  ADMaterialProperty<RankTwoTensor> & _F;

  // The mechanical deformation gradient (after excluding eigen deformation gradients from the total
  // deformation gradient)
  ADMaterialProperty<RankTwoTensor> & _Fm;

  // @{ Eigen deformation gradients
  std::vector<MaterialPropertyName> _Fg_names;
  std::vector<const ADMaterialProperty<RankTwoTensor> *> _Fgs;
  // @}

  // Total eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fg;

  // Inverse of total eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Fg_inv;
};
