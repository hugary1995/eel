#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class DeformationGradient : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  DeformationGradient(const InputParameters & parameters);

  void computeProperties() override;

protected:
  void initQpStatefulProperties() override;

  void computeQpProperties() override;

  /// Displacement variables
  std::vector<const ADVariableValue *> _disp;

  /// Gradient of displacements
  std::vector<const ADVariableGradient *> _grad_disp;

  /// Whether to apply volumetric locaking correction
  const bool _volumetric_locking_correction;

  /// The current element volume
  const Real & _current_elem_volume;

  /// Deformation gradient name
  const MaterialPropertyName _F_name;

  /// The total deformation gradient
  ADMaterialProperty<RankTwoTensor> & _F;

  /// The deformation gradient from the previous time step
  const MaterialProperty<RankTwoTensor> & _F_old;

  /// The deformation gradient rate
  ADMaterialProperty<RankTwoTensor> & _F_dot;

private:
  ADReal _J_avg;
};
