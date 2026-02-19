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
  params.addRequiredParam<MaterialPropertyName>("reference_normal_traction",
                                                "Referece normal traction");
  params.addRequiredParam<Real>("exponent", "Exponent of the power-law damage rate");
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
    _Tn0(getADMaterialProperty<Real>("reference_normal_traction")),
    _n(getParam<Real>("exponent")),
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
}

void
InterfaceTractionWithCreepDegradation::computeInterfaceTraction()
{
  // Update creep displacement jump
  returnMappingSolve(0, _D[_qp], _console);

  // Update traction
  _Tn[_qp] = _g[_qp] * _E[_qp] * _interface_displacement_jump[_qp](0);
  _interface_traction[_qp](0) = _Tn[_qp];
  _interface_traction[_qp](1) = _G[_qp] * _interface_displacement_jump[_qp](1);
  _interface_traction[_qp](2) = _G[_qp] * _interface_displacement_jump[_qp](2);

  // Update degradation
  using std::pow;
  _g[_qp] = pow(1 - _D[_qp], 2.0) * (1 - _eps) + _eps;
}

ADReal
InterfaceTractionWithCreepDegradation::initialGuess(const ADReal &)
{
  return _D_old[_qp];
}

Real
InterfaceTractionWithCreepDegradation::computeReferenceResidual(const ADReal &, const ADReal &)
{
  using std::abs;
  using std::pow;
  const auto g = pow(1 - _D_old[_qp], 2.0) * (1 - _eps) + _eps;
  const auto Tn = g * _E[_qp] * _interface_displacement_jump[_qp](0);
  const auto HTn = Tn > 0 ? 1 : 0;
  const auto Tnm = abs(Tn);
  const auto D_rate = pow(Tnm / _Tn0[_qp], _n) * HTn;
  return raw_value(D_rate * _dt);
}

ADReal
InterfaceTractionWithCreepDegradation::computeResidual(const ADReal &, const ADReal & D)
{
  using std::abs;
  using std::pow;
  const auto g = pow(1 - D, 2.0) * (1 - _eps) + _eps;
  const auto Tn = g * _E[_qp] * _interface_displacement_jump[_qp](0);
  const auto HTn = Tn > 0 ? 1 : 0;
  const auto Tnm = abs(Tn);
  const auto D_rate = pow(Tnm / _Tn0[_qp], _n) * HTn;
  return D - _D_old[_qp] - D_rate * _dt;
}

ADReal
InterfaceTractionWithCreepDegradation::computeDerivative(const ADReal &, const ADReal & D)
{
  using std::abs;
  using std::pow;
  const auto g = pow(1 - D, 2.0) * (1 - _eps) + _eps;
  const auto Tn = g * _E[_qp] * _interface_displacement_jump[_qp](0);
  const auto HTn = Tn > 0 ? 1 : 0;
  const auto Tnm = abs(Tn);
  const auto d_g_d_D = -2 * (1 - D) * (1 - _eps);
  const auto d_Tn_d_g = _E[_qp] * _interface_displacement_jump[_qp](0);
  const auto d_D_rate_d_Tn = _n * pow(Tnm / _Tn0[_qp], _n - 1) * HTn;
  return 1 - d_D_rate_d_Tn * d_Tn_d_g * d_g_d_D * _dt;
}
