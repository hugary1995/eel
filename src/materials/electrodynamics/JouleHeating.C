#include "JouleHeating.h"

registerMooseObject("StingrayApp", JouleHeating);

InputParameters
JouleHeating::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class computes volumetric heat source due to Joule heating from "
                             "electric displacement.");
  params.addRequiredCoupledVar("electric_potential", "The electrical potential");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "Name of the electric conductivity");
  params.addRequiredParam<MaterialPropertyName>("heat_source", "Name of the heat source");
  return params;
}

JouleHeating::JouleHeating(const InputParameters & parameters)
  : Material(parameters),
    _q(declareADProperty<Real>("heat_source")),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _sigma(getADMaterialProperty<RankTwoTensor>("electric_conductivity"))
{
}

void
JouleHeating::computeQpProperties()
{
  _q[_qp] = _sigma[_qp] * _grad_Phi[_qp] * _grad_Phi[_qp];
}
