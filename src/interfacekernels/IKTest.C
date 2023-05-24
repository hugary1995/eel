#include "IKTest.h"

registerMooseObject("EelApp", IKTest);

InputParameters
IKTest::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  return params;
}

IKTest::IKTest(const InputParameters & parameters) : ADInterfaceKernel(parameters) {}

ADReal
IKTest::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0;

  switch (type)
  {
    case Moose::Element:
      r += _grad_test[_i][_qp] * _grad_test[_i][_qp];
      break;
    case Moose::Neighbor:
      r += _grad_test_neighbor[_i][_qp] * _grad_test_neighbor[_i][_qp];
      break;
  }

  return r;
}
