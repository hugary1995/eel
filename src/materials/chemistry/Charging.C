#include "Charging.h"

registerMooseObject("StingrayApp", Charging);

InputParameters
Charging::validParams()
{
  InputParameters params = ChemicalDissipationDensity::validParams();
  params.addClassDescription(
      params.getClassDescription() +
      " This class defines the Joule heating due to concentration change of charged species.");
  params.addRequiredCoupledVar("electric_potential", "The electric potential");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "The electric conductivity");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  return params;
}

Charging::Charging(const InputParameters & parameters)
  : ChemicalDissipationDensity(parameters),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _sigma(getADMaterialPropertyByName<Real>(prependBaseName("electric_conductivity", true))),
    _F(getParam<Real>("faraday_constant"))
{
}

ADReal
Charging::computeQpChemicalDissipationDensity() const
{
  return _sigma[_qp] / _F * _grad_Phi[_qp] * _grad_c_dot[_qp];
}

ADReal
Charging::computeQpDChemicalDissipationDensityDConcentrationRate()
{
  return 0;
}

ADRealVectorValue
Charging::computeQpDChemicalDissipationDensityDConcentrationRateGradient()
{
  return _sigma[_qp] / _F * _grad_Phi[_qp];
}
