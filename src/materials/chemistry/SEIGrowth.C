// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "SEIGrowth.h"

registerMooseObject("EelApp", SEIGrowth);

InputParameters
SEIGrowth::validParams()
{
  InputParameters params = InterfaceMaterial::validParams();
  params += ADSingleVariableReturnMappingSolution::validParams();
  params.addClassDescription(
      "This object models the growth of solid electrolyte interphase (SEI).");
  params.addRequiredParam<MaterialPropertyName>("thickness", "Give the SEI layer thickness a name");
  params.addRequiredParam<MaterialPropertyName>("initial_thickness", "The initial thickness");
  params.addRequiredParam<MaterialPropertyName>("charge_transfer_mass_flux",
                                                "The charge transfer mass flux");
  params.addRequiredParam<Real>("molar_volume", "Molar volume of the interphase");
  params.addRequiredParam<Real>("characteristic_thickness",
                                "The characteristic thickness of the SEI");
  params.addRequiredParam<MaterialPropertyName>(
      "correction", "The correction coefficient depending on interphase geometry, porosity, etc.");
  params.addRequiredParam<Real>("activation_energy", "The activation energy for SEI growth");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  return params;
}

SEIGrowth::SEIGrowth(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    ADSingleVariableReturnMappingSolution(parameters),
    _h(declareADProperty<Real>("thickness")),
    _h_old(getMaterialPropertyOld<Real>("thickness")),
    _h0(getADMaterialProperty<Real>("initial_thickness")),
    _j(getMaterialPropertyOld<Real>("charge_transfer_mass_flux")),
    _Omega(getParam<Real>("molar_volume")),
    _hc(getParam<Real>("characteristic_thickness")),
    _A(getADMaterialProperty<Real>("correction")),
    _Q(getParam<Real>("activation_energy")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature"))
{
}

void
SEIGrowth::initQpStatefulProperties()
{
  _h[_qp] = _h0[_qp];
}

void
SEIGrowth::computeQpProperties()
{
  ADReal delta_h = 0;
  returnMappingSolve(0, delta_h, _console);
  _h[_qp] = _h_old[_qp] + delta_h;
}

Real
SEIGrowth::computeReferenceResidual(const ADReal &, const ADReal &)
{
  ADReal h = _h_old[_qp];
  ADReal h_rate =
      _A[_qp] * std::abs(_j[_qp]) * _Omega * std::exp(-_Q / _R / _T[_qp]) * std::exp(-h / _hc);
  return raw_value(h_rate);
}

ADReal
SEIGrowth::computeResidual(const ADReal &, const ADReal & delta_h)
{
  ADReal h = _h_old[_qp] + delta_h;
  ADReal h_rate =
      _A[_qp] * std::abs(_j[_qp]) * _Omega * std::exp(-_Q / _R / _T[_qp]) * std::exp(-h / _hc);
  return delta_h - h_rate * _dt;
}

ADReal
SEIGrowth::computeDerivative(const ADReal &, const ADReal & delta_h)
{
  ADReal h = _h_old[_qp] + delta_h;
  ADReal h_rate =
      _A[_qp] * std::abs(_j[_qp]) * _Omega * std::exp(-_Q / _R / _T[_qp]) * std::exp(-h / _hc);
  ADReal d_h_rate_d_delta_h = h_rate * (-1 / _hc);
  return 1 - d_h_rate_d_delta_h * _dt;
}
