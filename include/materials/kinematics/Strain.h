#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class Strain : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  Strain(const InputParameters & parameters);

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

  /// Total strain name
  const MaterialPropertyName _strain_name;

  /// The total strain
  ADMaterialProperty<RankTwoTensor> & _strain;

  /// The total strain from the previous time step
  const MaterialProperty<RankTwoTensor> & _strain_old;

  /// The strain rate
  ADMaterialProperty<RankTwoTensor> & _strain_dot;

private:
  ADReal _strain_tr_avg;
};
