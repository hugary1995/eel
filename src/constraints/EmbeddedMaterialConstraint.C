// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "EmbeddedMaterialConstraint.h"
#include "Function.h"

registerMooseObject("EelApp", EmbeddedMaterialConstraint);

InputParameters
EmbeddedMaterialConstraint::validParams()
{
  InputParameters params = OverlappingElementConstraint::validParams();
  params.addClassDescription(
      "Models the resistance coming from embedding a material inside another.");
  params.addRequiredParam<FunctionName>(
      "resistance",
      "The interface (contact) resistance betweem the embedded material and the matrix.");
  return params;
}

EmbeddedMaterialConstraint::EmbeddedMaterialConstraint(const InputParameters & parameters)
  : OverlappingElementConstraint(parameters), _R(getFunction("resistance"))
{
}

Real
EmbeddedMaterialConstraint::computeQpResidual(Moose::DGResidualType type)
{
  if (type == Moose::Element)
    return _test[_i][_qp] * (_u[_qp] - _u_neighbor[_qp]) / _R.value(_t, _constraint_q_point[_qp]);
  else if (type == Moose::Neighbor)
    return _test_neighbor[_i][_qp] * (_u_neighbor[_qp] - _u[_qp]) /
           _R.value(_t, _constraint_q_point[_qp]);
  else
    mooseError("Internal error");

  return 0;
}

Real
EmbeddedMaterialConstraint::computeQpJacobian(Moose::DGJacobianType type)
{
  if (type == Moose::ElementElement)
    return _test[_i][_qp] * _phi[_j][_qp] / _R.value(_t, _constraint_q_point[_qp]);
  else if (type == Moose::ElementNeighbor)
    return -_test[_i][_qp] * _phi_neighbor[_j][_qp] / _R.value(_t, _constraint_q_point[_qp]);
  else if (type == Moose::NeighborElement)
    return -_test_neighbor[_i][_qp] * _phi[_j][_qp] / _R.value(_t, _constraint_q_point[_qp]);
  else if (type == Moose::NeighborNeighbor)
    return _test_neighbor[_i][_qp] * _phi_neighbor[_j][_qp] /
           _R.value(_t, _constraint_q_point[_qp]);
  else
    mooseError("Internal error");

  return 0;
}
