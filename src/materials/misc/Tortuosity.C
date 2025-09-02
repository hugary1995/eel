#include "Tortuosity.h"

registerMooseObject("EelApp", Tortuosity);

InputParameters
Tortuosity::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredParam<MaterialPropertyName>("tortuosity", "The tortuosity");
  params.addRequiredCoupledVar("variable",
                               "The variable whose gradient is used to compute the tortuosity");
  params.addRequiredParam<MaterialPropertyName>("flux_ref", "The reference flux");
  return params;
}

Tortuosity::Tortuosity(const InputParameters & parameters)
  : Material(parameters),
    _tau(declareADProperty<Real>("tortuosity")),
    _grad_u(adCoupledGradient("variable")),
    _flux_ref(getADMaterialProperty<RealVectorValue>("flux_ref"))
{
}

void
Tortuosity::computeQpProperties()
{
  _tau[_qp] = 1 - _grad_u[_qp].unit() * _flux_ref[_qp].unit();
}
