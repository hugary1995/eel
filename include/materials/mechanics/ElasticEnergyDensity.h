// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

class ElasticEnergyDensity : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ElasticEnergyDensity(const InputParameters & parameters);

protected:
  /// Name of the elastic energy density
  const MaterialPropertyName _energy_name;

  /// Deformation gradient name
  const MaterialPropertyName _F_name;

  /// Deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _F;

  /// Deformation gradient rate
  const ADMaterialProperty<RankTwoTensor> & _F_dot;

  /// The elastic energy density
  ADMaterialProperty<Real> & _psi_dot;

  /// Derivative of the elastic energy density w.r.t. the deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_dot_d_F_dot;
};
