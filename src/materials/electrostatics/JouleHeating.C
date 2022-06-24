#include "JouleHeating.h"

InputParameters
JouleHeating::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes volumetric heat source due to Joule heating from "
                             "electric displacement.");
  params.addRequiredCoupledVar("electric_potential", "The electrical potential");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "Name of the electric conductivity");
  params.addRequiredParam<MaterialPropertyName>("joule_heating",
                                                "Give Joule heating a name (symbol)");
  return params;
}

JouleHeating::JouleHeating(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _q(declareADProperty<Real>(prependBaseName("joule_heating", true))),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _sigma(getADMaterialPropertyByName<Real>(prependBaseName("electric_conductivity", true)))
{
}

void
JouleHeating::computeQpProperties()
{
  _q[_qp] = _sigma[_qp] * _grad_Phi[_qp] * _grad_Phi[_qp];
}
