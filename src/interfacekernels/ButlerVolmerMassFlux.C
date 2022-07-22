#include "ButlerVolmerMassFlux.h"

registerMooseObject("StingrayApp", ButlerVolmerMassFlux);

InputParameters
ButlerVolmerMassFlux::validParams()
{
  InputParameters params = ButlerVolmerCondition::validParams();
  params.addClassDescription(
      "The Butler-Volmer condition for mass flux across the electrode/electrolyte interface. "
      "Note that the boundary this interface kernel acts on should be on the elctrode subdomain.");
  params.addRequiredCoupledVar("electrode_electric_potential",
                               "Electric potential in the electrode");
  params.addRequiredCoupledVar("electrolyte_electric_potential",
                               "Electric potential in the electrolyte");
  return params;
}

ButlerVolmerMassFlux::ButlerVolmerMassFlux(const InputParameters & parameters)
  : ButlerVolmerCondition(parameters),
    _Phi_s(adCoupledValue("electrode_electric_potential")),
    _Phi_e(adCoupledNeighborValue("electrolyte_electric_potential"))
{
}

ADReal
ButlerVolmerMassFlux::computeQpFlux() const
{
  // Surface overpotential
  ADReal eta = electrodeElectricPotential() - electrolyteElectricPotential();

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _alpha * _F / _R / T;
  ADReal i = _i0 * (std::exp(coef * eta) - std::exp(-coef * eta));

  // Concentration-dependent OCP
  ADReal c_s = electrodeConcentration() / _c_s_max;
  ADReal c_e = electrolyteConcentration() / _c_e_max;
  i *= std::pow(c_s, _n) * std::pow(1 - c_s, 1 - _n);
  i *= std::pow(c_e, _n) * std::pow(1 - c_e, 1 - _n);

  return i;
}