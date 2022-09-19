#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

template <bool>
class DualChemicalEnergyDensityBase;

template <>
class DualChemicalEnergyDensityBase</*condensed = */ false>
  : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams()
  {
    InputParameters params = DerivativeMaterialInterface<Material>::validParams();
    params.addRequiredCoupledVar("chemical_potential", "The chemical potential variable");
    return params;
  }

  DualChemicalEnergyDensityBase(const InputParameters & parameters)
    : DerivativeMaterialInterface<Material>(parameters),
      _mu_name(getVar("chemical_potential", 0)->name()),
      _grad_mu(adCoupledGradient("chemical_potential"))
  {
  }

protected:
  /// The chemical potential variable
  const VariableName _mu_name;

  /// The gradient of the chemical potential
  const ADVariableGradient & _grad_mu;
};

template <>
class DualChemicalEnergyDensityBase</*condensed = */ true>
  : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams()
  {
    InputParameters params = DerivativeMaterialInterface<Material>::validParams();
    params.addRequiredParam<MaterialPropertyName>("chemical_potential",
                                                  "The chemical potential property name");
    return params;
  }

  DualChemicalEnergyDensityBase(const InputParameters & parameters)
    : DerivativeMaterialInterface<Material>(parameters),
      _mu_name(getParam<MaterialPropertyName>("chemical_potential")),
      _grad_mu(getADMaterialProperty<RealVectorValue>("∇" + _mu_name))
  {
  }

protected:
  /// The chemical potential variable
  const MaterialPropertyName _mu_name;

  /// The gradient of the chemical potential
  const ADMaterialProperty<RealVectorValue> & _grad_mu;
};

template <bool condensed>
class DualChemicalEnergyDensityTempl : public DualChemicalEnergyDensityBase<condensed>
{
public:
  static InputParameters validParams();

  DualChemicalEnergyDensityTempl(const InputParameters & parameters);

protected:
  /// Name of the dual chemical energy density
  const MaterialPropertyName _energy_name;

  /// The dual chemical energy density
  ADMaterialProperty<Real> & _zeta;

  /// Derivative of the dual chemical energy density w.r.t. the chemical potential gradient
  ADMaterialProperty<RealVectorValue> & _d_zeta_d_grad_mu;

  using DualChemicalEnergyDensityBase<condensed>::_mu_name;
  using DualChemicalEnergyDensityBase<condensed>::_grad_mu;
};

typedef DualChemicalEnergyDensityTempl<false> DualChemicalEnergyDensity;
typedef DualChemicalEnergyDensityTempl<true> CondensedChemicalEnergyDensity;
