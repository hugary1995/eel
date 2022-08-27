#include "NeoHookeanSolid.h"

registerMooseObject("StingrayApp", NeoHookeanSolid);

InputParameters
NeoHookeanSolid::validParams()
{
  InputParameters params = ElasticEnergyDensity::validParams();
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
  _d_psi_dot_d_F_dot[_qp] = d_psi_d_Fm.initialContraction(_d_Fm_d_F[_qp]);

  if (_Fs || _Ft)
  {
    usingTensorIndices(i, j, k, l);
    const auto I = ADRankTwoTensor::Identity();
    const auto A = Fm_inv_t.times<i, j, k, l>(Fm_inv_t);
    const auto B = Fm_inv_t.times<i, l, j, k>(Fm_inv_t);
    const auto II = I.times<i, k, j, l>(I);
    const auto d_2_psi_d_Fm_2 = lambda * (A - std::log(Jm) * B) + G * (II + B);

    if (_Fs)
      (*_d_psi_dot_d_lnc)[_qp] = (d_2_psi_d_Fm_2 * (*_d_Fm_d_Fs)[_qp] * (*_d_Fs_d_lnc)[_qp])
                                     .initialContraction(_d_Fm_d_F[_qp])
                                     .doubleContraction(_F_dot[_qp]);

    if (_Ft)
      (*_d_psi_dot_d_lnT)[_qp] = (d_2_psi_d_Fm_2 * (*_d_Fm_d_Ft)[_qp] * (*_d_Ft_d_lnT)[_qp])
                                     .initialContraction(_d_Fm_d_F[_qp])
                                     .doubleContraction(_F_dot[_qp]);
  }

  _psi_dot[_qp] = _d_psi_dot_d_F_dot[_qp].doubleContraction(_F_dot[_qp]);
}
