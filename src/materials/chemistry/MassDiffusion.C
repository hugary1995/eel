#include "MassDiffusion.h"

registerMooseObject("EelApp", MassDiffusion);
registerMooseObject("EelApp", CondensedMassDiffusion);

template <bool condensed>
InputParameters
MassDiffusionTempl<condensed>::validParams()
{
  InputParameters params = DualChemicalEnergyDensityTempl<condensed>::validParams();
  params.addRequiredParam<MaterialPropertyName>("mobility", "The mobility of the species");
  return params;
}

template <bool condensed>
MassDiffusionTempl<condensed>::MassDiffusionTempl(const InputParameters & parameters)
  : DualChemicalEnergyDensityTempl<condensed>(parameters),
    _M(this->template getADMaterialProperty<Real>("mobility"))
{
}

template <bool condensed>
void
MassDiffusionTempl<condensed>::computeQpProperties()
{
  _d_zeta_d_grad_mu[_qp] = _M[_qp] * _grad_mu[_qp];
  _zeta[_qp] = 0.5 * _d_zeta_d_grad_mu[_qp] * _grad_mu[_qp];
}

template class MassDiffusionTempl<false>;
template class MassDiffusionTempl<true>;
