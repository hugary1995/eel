// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class ChemicalPotentialTest : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ChemicalPotentialTest(const InputParameters & parameters);

  void computeQpProperties() override;

protected:
  /// Chemical potential
  ADMaterialProperty<Real> & _mu;

  /// Energy names
  const std::vector<MaterialPropertyName> _psi_names;

  /// Energy derivatives
  std::vector<const ADMaterialProperty<Real> *> _d_psi_d_c_dot;

  /// Concentration
  const MooseVariable * _c_var;
};
