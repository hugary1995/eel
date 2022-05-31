// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class Strain : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  Strain(const InputParameters & parameters);

  virtual void computeProperties();

protected:
  virtual void initQpStatefulProperties();

  virtual void computeQpProperties();

  /// Displacement variables
  std::vector<const ADVariableValue *> _disp;

  /// Gradient of displacements
  std::vector<const ADVariableGradient *> _grad_disp;

  /// Whether to apply volumetric locaking correction
  const bool _volumetric_locking_correction;

  /// The current element volume
  const Real & _current_elem_volume;

  /// Total strain name
  const MaterialPropertyName _E_name;

  /// The total strain
  ADMaterialProperty<RankTwoTensor> & _E;

  /// The total strain from the previous time step
  const MaterialProperty<RankTwoTensor> & _E_old;

  /// The strain rate
  ADMaterialProperty<RankTwoTensor> & _E_dot;

private:
  ADReal _E_tr_avg;
};
