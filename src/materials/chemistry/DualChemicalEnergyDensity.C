#include "DualChemicalEnergyDensity.h"

InputParameters
DualChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the dual chemical energy density and its corresponding "
      "thermodynamic forces. We assume the dual chemical energy density depends "
      "on the gradient of chemical potential.");
  params.addRequiredCoupledVar("chemical_potential",
                               "The chemical potential associated with a chemical species");
  params.addRequiredParam<MaterialPropertyName>("dual_chemical_energy_density",
                                                "Name of the dual chemical energy density");
  return params;
}

DualChemicalEnergyDensity::DualChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("dual_chemical_energy_density")),
    _mu_var(getVar("chemical_potential", 0)),
    _grad_mu(adCoupledGradient("chemical_potential")),
    _zeta(declareADProperty<Real>(_energy_name)),
    _d_zeta_d_grad_mu(
        declarePropertyDerivative<RealVectorValue, true>(_energy_name, "∇" + _mu_var->name()))
{
}
