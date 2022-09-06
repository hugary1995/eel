#include "ButlerVolmerCurrentDensity.h"

registerMooseObject("EelApp", ButlerVolmerCurrentDensity);

InputParameters
ButlerVolmerCurrentDensity::validParams()
{
  InputParameters params = ButlerVolmerCondition::validParams();
  params.addClassDescription(
      "The Butler-Volmer condition for current density across the electrode/electrolyte interface. "
      "Note that the boundary this interface kernel acts on should be on the elctrode subdomain.");
  params.addCoupledVar("electrode_concentration",
                       "Concentration of the charged species in the electrode");
  params.addCoupledVar("electrolyte_concentration",
                       "Concentration of the charged species in the electrolyte");
  return params;
}

ButlerVolmerCurrentDensity::ButlerVolmerCurrentDensity(const InputParameters & parameters)
  : ButlerVolmerCondition(parameters),
    _c_s(isParamValid("electrode_concentration") ? &adCoupledValue("electrode_concentration")
                                                 : nullptr),
    _c_e(isParamValid("electrolyte_concentration")
             ? &adCoupledNeighborValue("electrolyte_concentration")
             : nullptr)
{
}

ADReal
ButlerVolmerCurrentDensity::computeQpFlux() const
{
  // Surface overpotential
  ADReal eta = electrodeElectricPotential() - electrolyteElectricPotential();

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _alpha * _F / _R / T;
  ADReal i = _i0 * (std::exp(coef * eta) - std::exp(-coef * eta));

  // Concentration-dependent OCP
  if (_c_s)
  {
    ADReal c = electrodeConcentration() / _c_s_max;
    i *= std::pow(c, _n) * std::pow(1 - c, 1 - _n);
  }
  if (_c_e)
  {
    ADReal c = electrolyteConcentration() / _c_e_max;
    i *= std::pow(c, _n) * std::pow(1 - c, 1 - _n);
  }

  return i;
}
