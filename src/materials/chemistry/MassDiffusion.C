#include "MassDiffusion.h"

registerMooseObject("StingrayApp", MassDiffusion);

InputParameters
MassDiffusion::validParams()
{
  InputParameters params = ChemicalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Fick's first law of mass diffusion.");
  params.addRequiredParam<MaterialPropertyName>("diffusivity", "The diffusion coefficient tensor");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addCoupledVar("temperature", "The temperature");
  return params;
}

MassDiffusion::MassDiffusion(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _D(getADMaterialProperty<RankTwoTensor>("diffusivity")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T_var(getVar("temperature", 0)),
    _T(adCoupledValue("temperature")),
    _d_G_d_lnT(declarePropertyDerivative<Real, true>(_energy_name, "ln(" + _T_var->name() + ")"))
{
}

void
MassDiffusion::computeQpProperties()
{
  _d_G_d_grad_lnc[_qp] = -_R * _T[_qp] * _D[_qp] * _grad_c[_qp];
  _G[_qp] = 0.5 * _d_G_d_grad_lnc[_qp] * _grad_c[_qp] / _c[_qp];
  _d_G_d_lnT[_qp] = _G[_qp];
}