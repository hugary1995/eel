#include "BulkChargeTransport.h"

registerMooseObject("StingrayApp", BulkChargeTransport);

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
  params.addParam<MaterialPropertyName>("deformation_gradient", "Name of the deformation gradient");
  return params;
}

BulkChargeTransport::BulkChargeTransport(const InputParameters & parameters)
  : ElectricalEnergyDensity(parameters),
    _sigma(getADMaterialProperty<RankTwoTensor>("electric_conductivity")),
    _d_E_d_lnT(isParamValid("temperature")
                   ? &declarePropertyDerivative<Real, true>(
                         _energy_name, "ln(" + getParam<VariableName>("temperature") + ")")
                   : nullptr),
    _F(hasADMaterialProperty<RankTwoTensor>("deformation_gradient")
           ? &getADMaterialProperty<RankTwoTensor>("deformation_gradient")
           : nullptr)
{
}

void
BulkChargeTransport::computeQpProperties()
{
  // Pull back the electric conductivity
  const ADRankTwoTensor F = _F ? (*_F)[_qp] : ADRankTwoTensor::Identity();
  const ADRankTwoTensor sigma_0 = F.det() * F.inverse().transpose() * _sigma[_qp] * F.inverse();

  _d_E_d_grad_Phi[_qp] = sigma_0 * _grad_Phi[_qp];
  _E[_qp] = 0.5 * _d_E_d_grad_Phi[_qp] * _grad_Phi[_qp];

  if (_d_E_d_lnT)
    (*_d_E_d_lnT)[_qp] = _d_E_d_grad_Phi[_qp] * _grad_Phi[_qp];
}
