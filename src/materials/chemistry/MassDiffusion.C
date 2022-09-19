#include "MassDiffusion.h"

registerMooseObject("EelApp", MassDiffusion);

InputParameters
MassDiffusion::validParams()
{
  InputParameters params = DualChemicalEnergyDensity::validParams();
  params.addRequiredParam<MaterialPropertyName>("mobility", "The mobility of the species");
  return params;
}

MassDiffusion::MassDiffusion(const InputParameters & parameters)
  : DualChemicalEnergyDensity(parameters), _M(getADMaterialProperty<Real>("mobility"))
{
}

void
MassDiffusion::computeQpProperties()
{
  _d_zeta_d_grad_mu[_qp] = -_M[_qp] * _grad_mu[_qp];
  _zeta[_qp] = 0.5 * _d_zeta_d_grad_mu[_qp] * _grad_mu[_qp];
}
