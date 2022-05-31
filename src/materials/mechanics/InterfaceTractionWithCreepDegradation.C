// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "InterfaceTractionWithCreepDegradation.h"

registerMooseObject("EelApp", InterfaceTractionWithCreepDegradation);

InputParameters
InterfaceTractionWithCreepDegradation::validParams()
{
  InputParameters params = ADCZMComputeLocalTractionTotalBase::validParams();
  params += ADSingleVariableReturnMappingSolution::validParams();
  params.addRequiredParam<MaterialPropertyName>("damage", "Interface damage");
  params.addRequiredParam<MaterialPropertyName>("degradation", "Interface degradation");
  params.addRequiredParam<MaterialPropertyName>("normal_stiffness", "Normal stiffness");
  params.addRequiredParam<MaterialPropertyName>("tangential_stiffness", "Tangential stiffness");
  params.addRequiredParam<MaterialPropertyName>("normal_traction", "Normal traction");
  params.addRequiredParam<MaterialPropertyName>("creep_displacement_jump",
                                                "The creep displacement jump name");
  params.addRequiredParam<MaterialPropertyName>("energy_release_rate", "The energy release rate");
  params.addRequiredParam<MaterialPropertyName>("fracture_driving_energy",
                                                "The name of the fracture driving energy");
  params.addRequiredParam<MaterialPropertyName>("creep_coefficient", "The creep coefficient");
  params.addRequiredParam<Real>("activation_energy", "The creep activation energy");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature variable");
  params.addRequiredParam<MaterialPropertyName>("reference_normal_traction",
                                                "Referece normal traction");
  params.addRequiredParam<Real>("creep_exponent", "Exponent of the power-law creep");
  params.addRequiredParam<Real>("residual_stiffness",
                                "A small stiffness to prevent numerical issue");
  return params;
}

InterfaceTractionWithCreepDegradation::InterfaceTractionWithCreepDegradation(
    const InputParameters & parameters)
  : ADCZMComputeLocalTractionTotalBase(parameters),
    ADSingleVariableReturnMappingSolution(parameters),
    _D(declareADProperty<Real>("damage")),
    _D_old(getMaterialPropertyOld<Real>("damage")),
    _g(declareADProperty<Real>("degradation")),
    _juc(declareADProperty<Real>("creep_displacement_jump")),
    _juc_old(getMaterialPropertyOld<Real>("creep_displacement_jump")),
    _Gc(getADMaterialProperty<Real>("energy_release_rate")),
    _psi(declareADProperty<Real>("fracture_driving_energy")),
    _psi_old(getMaterialPropertyOld<Real>("fracture_driving_energy")),
    _A(getADMaterialProperty<Real>("creep_coefficient")),
    _Q(getParam<Real>("activation_energy")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _Tn0(getADMaterialProperty<Real>("reference_normal_traction")),
    _n(getParam<Real>("creep_exponent")),
    _E(getADMaterialProperty<Real>("normal_stiffness")),
    _G(getADMaterialProperty<Real>("tangential_stiffness")),
    _Tn(declareADProperty<Real>("normal_traction")),
    _eps(getParam<Real>("residual_stiffness"))
{
}

void
InterfaceTractionWithCreepDegradation::initQpStatefulProperties()
{
  _D[_qp] = 0;
  _juc[_qp] = 0;
  _psi[_qp] = 0;
}

void
InterfaceTractionWithCreepDegradation::computeInterfaceTraction()
{
  // Update damage
  if (_psi_old[_qp] > _Gc[_qp])
    _D[_qp] = (_psi_old[_qp] - _Gc[_qp]) / _psi_old[_qp];
  _D[_qp] = std::max(_D[_qp], _D_old[_qp]);
  _g[_qp] = std::pow(1 - _D[_qp], 2.0) * (1 - _eps) + _eps;

  // Update creep displacement jump
  returnMappingSolve(0, _juc[_qp], _console);

  // Update traction
  _Tn[_qp] = _g[_qp] * _E[_qp] * (_interface_displacement_jump[_qp](0) - _juc[_qp]);
  _interface_traction[_qp](0) = _Tn[_qp];
  _interface_traction[_qp](1) = _G[_qp] * _interface_displacement_jump[_qp](1);
  _interface_traction[_qp](2) = _G[_qp] * _interface_displacement_jump[_qp](2);

  // Update damage driving energy
  _psi[_qp] = 0.5 * _E[_qp] * std::pow(_interface_displacement_jump[_qp](0) - _juc[_qp], 2.0) +
              _Tn0[_qp] * _juc[_qp];
}

ADReal
InterfaceTractionWithCreepDegradation::initialGuess(const ADReal &)
{
  return _juc_old[_qp];
}

Real
InterfaceTractionWithCreepDegradation::computeReferenceResidual(const ADReal &, const ADReal &)
{
  return raw_value(_A[_qp] * std::exp(-_Q / _R / _T[_qp]));
}

ADReal
InterfaceTractionWithCreepDegradation::computeResidual(const ADReal &, const ADReal & juc)
{
  ADReal Tn = _g[_qp] * _E[_qp] * (_interface_displacement_jump[_qp](0) - juc);
  ADReal juc_rate = _A[_qp] * std::exp(-_Q / _R / _T[_qp]) * std::pow(Tn / _g[_qp] / _Tn0[_qp], _n);
  return juc - _juc_old[_qp] - juc_rate * _dt;
}

ADReal
InterfaceTractionWithCreepDegradation::computeDerivative(const ADReal &, const ADReal & juc)
{
  ADReal Tn = _g[_qp] * _E[_qp] * (_interface_displacement_jump[_qp](0) - juc);
  ADReal juc_rate = _A[_qp] * std::exp(-_Q / _R / _T[_qp]) * std::pow(Tn / _g[_qp] / _Tn0[_qp], _n);
  ADReal djuc_rate_djuc = -juc_rate * _n / Tn * _g[_qp] * _E[_qp];
  return 1 - djuc_rate_djuc * _dt;
}
