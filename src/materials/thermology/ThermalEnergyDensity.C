#include "ThermalEnergyDensity.h"

InputParameters
ThermalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription("This class computes the thermal energy density and its corresponding "
                             "thermodynamic forces. We assume the thermal energy density depends "
                             "on the gradient of log temperature.");
  params.addRequiredCoupledVar(
      "temperature", "temperature of the species associated with this thermal energy density.");
  params.addRequiredParam<MaterialPropertyName>("thermal_energy_density",
                                                "Name of the thermal energy density");
  return params;
}

ThermalEnergyDensity::ThermalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("thermal_energy_density")),
    _T_var(getVar("temperature", 0)),
    _T(adCoupledValue("temperature")),
    _grad_T(adCoupledGradient("temperature")),
    _H(declareADProperty<Real>(_energy_name)),
    _d_H_d_grad_lnT(declarePropertyDerivative<RealVectorValue, true>(_energy_name,
                                                                     "∇ln(" + _T_var->name() + ")"))
{
}
