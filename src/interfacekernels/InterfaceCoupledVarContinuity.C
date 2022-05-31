// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "InterfaceCoupledVarContinuity.h"

registerMooseObject("EelApp", InterfaceCoupledVarContinuity);

InputParameters
InterfaceCoupledVarContinuity::validParams()
{
  InputParameters params = InterfaceContinuity::validParams();
  params.addClassDescription("Enforcing continuity of a coupled var across an interface");
  params.addRequiredCoupledVar("v", "Enforce continuity of this coupled variable");
  params.addRequiredCoupledVar("v_neighbor", "Enforce continuity of this coupled variable");
  return params;
}

InterfaceCoupledVarContinuity::InterfaceCoupledVarContinuity(const InputParameters & parameters)
  : InterfaceContinuity(parameters),
    _v(adCoupledValue("v")),
    _v_neighbor(adCoupledNeighborValue("v_neighbor"))
{
}

ADReal
InterfaceCoupledVarContinuity::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty * (_v[_qp] - _v_neighbor[_qp]);

    case Moose::Neighbor:
      return -_test_neighbor[_i][_qp] * _penalty * (_v[_qp] - _v_neighbor[_qp]);
  }

  return 0;
}
