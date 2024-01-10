// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "Material.h"

/**
 * @brief The magnetizing field (not to be confused with magnetic field) as a function of magnetic
 * vector potential.
 *
 * \f$ H = \dfrac{1}{\mu} \nabla \times A \f$, where \f$ \mu \f$ is the magnetic permeability, and
 * \f$ A \f$ is the magnetic vector potential.
 *
 */
class MagnetizingField : public Material
{
public:
  static InputParameters validParams();

  MagnetizingField(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Gradients of the magnetic vector field
  std::vector<const ADVariableGradient *> _grad_A;

  /// The magnetic permeability
  const ADMaterialProperty<Real> & _mu;

  /// The magnetizing field
  ADMaterialProperty<RealVectorValue> & _H;
};
