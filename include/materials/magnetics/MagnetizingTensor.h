// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"

/**
 * @brief The magnetizing tensor
 *
 */
class MagnetizingTensor : public Material
{
public:
  static InputParameters validParams();

  MagnetizingTensor(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The magnetic vector field
  std::vector<const ADVariableValue *> _A;

  /// Gradients of the magnetic vector field
  std::vector<const ADVariableGradient *> _grad_A;

  /// The magnetic permeability
  const ADMaterialProperty<Real> & _mu;

  /// The magnetizing field
  ADMaterialProperty<RankTwoTensor> & _H;
};
