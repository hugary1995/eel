// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "DualChemicalEnergyDensity.h"

InputParameters
DualChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the dual chemical energy density and its corresponding "
      "thermodynamic forces. We assume the dual chemical energy density depends "
      "on the gradient of chemical potential.");
  params.addRequiredParam<MaterialPropertyName>("chemical_potential", "The chemical potential");
  params.addRequiredParam<MaterialPropertyName>("dual_chemical_energy_density",
                                                "Name of the dual chemical energy density");
  return params;
}

DualChemicalEnergyDensity::DualChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("dual_chemical_energy_density")),
    _mu_name(getParam<MaterialPropertyName>("chemical_potential")),
    _grad_mu(getADMaterialProperty<RealVectorValue>("∇" + _mu_name)),
    _zeta(declareADProperty<Real>(_energy_name)),
    _d_zeta_d_grad_mu(
        declarePropertyDerivative<RealVectorValue, true>(_energy_name, "∇" + _mu_name))
{
}
