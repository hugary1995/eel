// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "WeldedInterfaceTraction.h"

registerMooseObject("EelApp", WeldedInterfaceTraction);

InputParameters
WeldedInterfaceTraction::validParams()
{
  InputParameters params = ADCZMComputeLocalTractionTotalBase::validParams();
  params.addRequiredParam<MaterialPropertyName>("normal_stiffness", "Normal stiffness");
  params.addRequiredParam<MaterialPropertyName>("tangential_stiffness", "Tangential stiffness");
  params.addRequiredParam<MaterialPropertyName>("phase",
                                                "The phase value, 0 for solid, 1 for liquid");
  params.addRequiredParam<MaterialPropertyName>("phase_history_maximum",
                                                "History maximum of the phase value");
  params.addRequiredParam<Real>("residual_stiffness",
                                "A small stiffness to prevent numerical issue");
  return params;
}

WeldedInterfaceTraction::WeldedInterfaceTraction(const InputParameters & parameters)
  : ADCZMComputeLocalTractionTotalBase(parameters),
    _phi_max(declareADProperty<Real>("phase_history_maximum")),
    _phi_max_old(getMaterialPropertyOld<Real>("phase_history_maximum")),
    _phi(getADMaterialProperty<Real>("phase")),
    _E(getADMaterialProperty<Real>("normal_stiffness")),
    _G(getADMaterialProperty<Real>("tangential_stiffness")),
    _eps(getParam<Real>("residual_stiffness"))
{
}

void
WeldedInterfaceTraction::initQpStatefulProperties()
{
  _phi_max[_qp] = 0;
}

void
WeldedInterfaceTraction::computeInterfaceTraction()
{
  _phi_max[_qp] = _phi_max_old[_qp];
  if (_phi[_qp] > _phi_max[_qp])
    _phi_max[_qp] = _phi[_qp];

  ADReal g = (_phi_max[_qp] * _phi_max[_qp]) * (1 - _eps) + _eps;

  _interface_traction[_qp](0) = g * _E[_qp] * _interface_displacement_jump[_qp](0);
  _interface_traction[_qp](1) = g * _G[_qp] * _interface_displacement_jump[_qp](1);
  _interface_traction[_qp](2) = g * _G[_qp] * _interface_displacement_jump[_qp](2);
}
