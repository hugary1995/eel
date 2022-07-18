#include "ElectrochemicalKinetics.h"

registerMooseObject("StingrayApp", ElectrochemicalKinetics);

InputParameters
ElectrochemicalKinetics::validParams()
{
  InputParameters params = ElectricalEnergyDensity::validParams();
  params.addClassDescription(
      params.getClassDescription() +
      " This class defines the electrical ElectrochemicalKinetics potential.");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("charge_number", "The charge number");
  params.addRequiredCoupledVar("concentration", "Concentration of the charged species");
  return params;
}

ElectrochemicalKinetics::ElectrochemicalKinetics(const InputParameters & parameters)
  : ElectricalEnergyDensity(parameters),
    _F(getParam<Real>("faraday_constant")),
    _z(getParam<Real>("charge_number")),
    _c_dot(adCoupledDot("concentration"))
{
}

ADReal
ElectrochemicalKinetics::computeQpElectricalEnergyDensity() const
{
  return _F * _z * _c_dot[_qp] * _Phi[_qp];
}

ADReal
ElectrochemicalKinetics::computeQpDElectricalEnergyDensityDElectricalPotential()
{
  return _F * _z * _c_dot[_qp];
}

ADRealVectorValue
ElectrochemicalKinetics::computeQpDElectricalEnergyDensityDElectricalPotentialGradient()
{
  return ADRealVectorValue(0, 0, 0);
}

ADRankTwoTensor
ElectrochemicalKinetics::computeQpDElectricalEnergyDensityDDeformationGradient()
{
  ADRankTwoTensor zero;
  return zero;
}
