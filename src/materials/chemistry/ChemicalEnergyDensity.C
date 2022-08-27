#include "ChemicalEnergyDensity.h"

InputParameters
ChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the chemical energy density and its corresponding "
      "thermodynamic forces. We assume the chemical energy density depends "
      "on the gradients of log concentrations.");
  params.addRequiredCoupledVar(
      "concentration",
      "Concentration of the species associated with this chemical energy density.");
  params.addRequiredParam<MaterialPropertyName>("chemical_energy_density",
                                                "Name of the chemical energy density");
  return params;
}

ChemicalEnergyDensity::ChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("chemical_energy_density")),
    _c_var(getVar("concentration", 0)),
    _c(adCoupledValue("concentration")),
    _grad_c(adCoupledGradient("concentration")),
    _G(declareADProperty<Real>(_energy_name)),
    _d_G_d_grad_lnc(declarePropertyDerivative<RealVectorValue, true>(_energy_name,
                                                                     "∇ln(" + _c_var->name() + ")"))
{
}
