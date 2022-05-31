// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "CoupledVarDirichletBC.h"

registerMooseObject("EelApp", CoupledVarDirichletBC);

InputParameters
CoupledVarDirichletBC::validParams()
{
  InputParameters params = DirichletBCBase::validParams();
  params.addRequiredCoupledVar("value", "Value of the BC");
  params.addClassDescription("Imposes the essential boundary condition $u=g$");
  return params;
}

CoupledVarDirichletBC::CoupledVarDirichletBC(const InputParameters & parameters)
  : DirichletBCBase(parameters), _value(coupledValue("value"))
{
}

Real
CoupledVarDirichletBC::computeQpValue()
{
  return _value[_qp];
}
