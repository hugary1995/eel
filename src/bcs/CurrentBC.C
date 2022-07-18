#include "CurrentBC.h"

registerMooseObject("StingrayApp", CurrentBC);

InputParameters
CurrentBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();

  params.addRequiredCoupledVar("concentration", "The concentration of the charged species");
  params.addRequiredParam<FunctionName>("env_concentration", "Cocentration of the environment");
  params.addRequiredParam<Real>("max_concentration", "Maximum concentration");
  params.addRequiredParam<Real>("current", "Magnitude of the applied current");

  return params;
}

CurrentBC::CurrentBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _c(adCoupledValue("concentration")),
    _c_env(getFunction("env_concentration")),
    _c_max(getParam<Real>("max_concentration")),
    _current(getParam<Real>("current"))
{
}

ADReal
CurrentBC::computeQpResidual()
{
  return -_test[_i][_qp] * _current * (_c_env.value(_t, _q_point[_qp]) - _c[_qp]) / _c_max;
}
