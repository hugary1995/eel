// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "Material.h"

class EddyCurrent : public Material
{
public:
  static InputParameters validParams();

  EddyCurrent(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Real part of the magnetic vector field
  std::vector<const ADVariableValue *> _Are;

  /// Imaginery part of the magnetic vector field
  std::vector<const ADVariableValue *> _Aim;

  /// The frequency
  const ADMaterialProperty<Real> & _omega;

  /// The electric conductivity
  const ADMaterialProperty<Real> & _sigma;

  /// The volumetric power
  ADMaterialProperty<Real> & _ie;
};
