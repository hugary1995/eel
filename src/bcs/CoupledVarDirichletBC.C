//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

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
