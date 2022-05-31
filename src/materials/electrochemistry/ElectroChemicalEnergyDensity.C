// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ElectroChemicalEnergyDensity.h"

InputParameters
ElectroChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the electrochemical energy density and its corresponding "
      "thermodynamic forces. We assume the electrochemical energy density depends "
      "on the gradients of electrical potential and chemical potential");
  params.addRequiredCoupledVar("electric_potential", "The electric potential");
  params.addRequiredParam<MaterialPropertyName>("chemical_potential", "The chemical potential");
  params.addRequiredParam<MaterialPropertyName>("electrochemical_energy_density",
                                                "Name of the electrochemical energy density");
  return params;
}

ElectroChemicalEnergyDensity::ElectroChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("electrochemical_energy_density")),
    _Phi_var(getVar("electric_potential", 0)),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _mu_name(getParam<MaterialPropertyName>("chemical_potential")),
    _grad_mu(getADMaterialProperty<RealVectorValue>("∇" + _mu_name)),
    _E(declareADProperty<Real>(_energy_name)),
    _d_E_d_grad_Phi(
        declarePropertyDerivative<RealVectorValue, true>(_energy_name, "∇" + _Phi_var->name())),
    _d_E_d_grad_mu(declarePropertyDerivative<RealVectorValue, true>(_energy_name, "∇" + _mu_name))
{
}
