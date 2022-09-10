#include "EntropicChemicalEnergyDensity.h"

registerMooseObject("EelApp", EntropicChemicalEnergyDensity);

InputParameters
EntropicChemicalEnergyDensity::validParams()
{
  InputParameters params = ChemicalEnergyDensity::validParams();
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar(
      "reference_concentration",
      "The reference concentration at which the entropic chemical energy density is zero");
  params.addParam<bool>(
      "condense_dual_problem",
      false,
      "If we condense out the dual problem, some additional second derivatives need "
      "to be computed here.");
  return params;
}

EntropicChemicalEnergyDensity::EntropicChemicalEnergyDensity(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _c0(coupledValue("reference_concentration")),
    _condensation(getParam<bool>("condense_dual_problem")),
    _d_2_psi_dot_d_c_dot_d_c(_condensation
                                 ? &declarePropertyDerivative<Real, true>(
                                       "dot(" + _energy_name + ")", "dot(" + _c_name + ")", _c_name)
                                 : nullptr),
    _d_2_psi_dot_d_c_dot_d_T(
        _condensation ? &declarePropertyDerivative<Real, true>("dot(" + _energy_name + ")",
                                                               "dot(" + _c_name + ")",
                                                               getVar("temperature", 0)->name())
                      : nullptr)
{
}

void
EntropicChemicalEnergyDensity::computeQpProperties()
{
  _d_psi_dot_d_c_dot[_qp] = _R * _T[_qp] * std::log(_c[_qp] / _c0[_qp]);
  _psi_dot[_qp] = _d_psi_dot_d_c_dot[_qp] * _c_dot[_qp];

  if (_condensation)
  {
    (*_d_2_psi_dot_d_c_dot_d_c)[_qp] = _R * _T[_qp] / _c[_qp];
    (*_d_2_psi_dot_d_c_dot_d_T)[_qp] = _R * std::log(_c[_qp] / _c0[_qp]);
  }
}
