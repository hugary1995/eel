#include "NeoHookeanSolid.h"

registerMooseObject("StingrayApp", NeoHookeanSolid);

InputParameters
NeoHookeanSolid::validParams()
{
  InputParameters params = MechanicalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Neo-Hookean elastic energy density.");
  params.addRequiredParam<MaterialPropertyName>("lambda", "Lame's first parameter");
  params.addRequiredParam<MaterialPropertyName>("shear_modulus", "The shear modulus");
  return params;
}

NeoHookeanSolid::NeoHookeanSolid(const InputParameters & parameters)
  : MechanicalEnergyDensity(parameters),
    _lambda(getADMaterialProperty<Real>("lambda")),
    _G(getADMaterialProperty<Real>("shear_modulus"))
{
}

void
NeoHookeanSolid::computeQpProperties()
{
  const auto lambda = _lambda[_qp];
  const auto G = _G[_qp];
  const auto Fm = _Fm[_qp];
  const auto Fm_inv_t = Fm.inverse().transpose();
  const auto Jm = Fm.det();

  const ADRankTwoTensor d_psi_d_Fm = lambda * std::log(Jm) * Fm_inv_t + G * (Fm - Fm_inv_t);
  _d_psi_dot_d_F_dot[_qp] = d_psi_d_Fm * _Fg[_qp].inverse().transpose();
  _psi_dot[_qp] = _d_psi_dot_d_F_dot[_qp].doubleContraction(_F_dot[_qp]);

  if (_Fs)
  {
    ADReal p = -_d_psi_dot_d_F_dot[_qp].doubleContraction(_F[_qp] * (*_Fs)[_qp].inverse()) / 3;
    (*_d_psi_d_c)[_qp] = (*_d_Js_d_c)[_qp] * p;
  }
}
