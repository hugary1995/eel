#include "ElectricalEnergyDensity.h"

InputParameters
ElectricalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the electrical energy density and its corresponding "
      "thermodynamic forces. We assume the electrical energy density depends "
      "on at least the deformation gradient and the gradient of electrical potential");
  params.addRequiredCoupledVar("electric_potential", "The electrical potential");
  params.addRequiredParam<MaterialPropertyName>("electrical_energy_density",
                                                "Name of the electrical energy density");
  return params;
}

ElectricalEnergyDensity::ElectricalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("electrical_energy_density")),
    _Phi_var(getVar("electric_potential", 0)),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _E(declareADProperty<Real>(_energy_name)),
    _d_E_d_grad_Phi(
        declarePropertyDerivative<RealVectorValue, true>(_energy_name, "∇" + _Phi_var->name()))
{
}
