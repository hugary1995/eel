#include "ChemicalEnergyDensity.h"

InputParameters
ChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "This class computes the chemical energy density and its corresponding "
      "thermodynamic forces. We assume the chemical energy density depends "
      "on the chemical concentration.");
  params.addRequiredCoupledVar("concentration",
                               "The chemical concentration associated with a chemical species");
  params.addRequiredParam<MaterialPropertyName>("chemical_energy_density",
                                                "Name of the chemical energy density");
  return params;
}

ChemicalEnergyDensity::ChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _energy_name(getParam<MaterialPropertyName>("chemical_energy_density")),
    _c_var(getVar("concentration", 0)),
    _c(adCoupledValue("concentration")),
    _c_dot(adCoupledDot("concentration")),
    _psi_dot(declareADProperty<Real>("dot(" + _energy_name + ")")),
    _d_psi_dot_d_c_dot(declarePropertyDerivative<Real, true>("dot(" + _energy_name + ")",
                                                             "dot(" + _c_var->name() + ")"))
{
}
