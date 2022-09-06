#include "BulkChargeTransport.h"

registerMooseObject("EelApp", BulkChargeTransport);

InputParameters
BulkChargeTransport::validParams()
{
  InputParameters params = ElectricalEnergyDensity::validParams();
  params.addClassDescription(
      params.getClassDescription() +
      " This class defines the electrical potential for charge transfer in the bulk");
  params.addRequiredParam<MaterialPropertyName>("electric_conductivity",
                                                "The electric conductivity tensor");
  params.addParam<VariableName>("temperature", "The temperature");
  return params;
}

BulkChargeTransport::BulkChargeTransport(const InputParameters & parameters)
  : ElectricalEnergyDensity(parameters),
    _sigma(getADMaterialProperty<Real>("electric_conductivity")),
    _d_E_d_lnT(isParamValid("temperature")
                   ? &declarePropertyDerivative<Real, true>(
                         _energy_name, "ln(" + getParam<VariableName>("temperature") + ")")
                   : nullptr)
{
}

void
BulkChargeTransport::computeQpProperties()
{
  _d_E_d_grad_Phi[_qp] = _sigma[_qp] * _grad_Phi[_qp];
  _E[_qp] = 0.5 * _d_E_d_grad_Phi[_qp] * _grad_Phi[_qp];

  if (_d_E_d_lnT)
    (*_d_E_d_lnT)[_qp] = _d_E_d_grad_Phi[_qp] * _grad_Phi[_qp];
}
