#include "NeoHookeanSolid.h"

registerMooseObject("EelApp", NeoHookeanSolid);

InputParameters
NeoHookeanSolid::validParams()
{
  InputParameters params = MechanicalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Neo-Hookean elastic energy density.");
  params.addRequiredParam<MaterialPropertyName>("lambda", "Lame's first parameter");
  params.addRequiredParam<MaterialPropertyName>("shear_modulus", "The shear modulus");
  params.addParam<MaterialPropertyName>(
      "non_swelling_pressure",
      "Non swelling portion of the pressure used to drive the diffusion of chemical species.");
  return params;
}

NeoHookeanSolid::NeoHookeanSolid(const InputParameters & parameters)
  : MechanicalEnergyDensity(parameters),
    _lambda(getADMaterialProperty<Real>("lambda")),
    _G(getADMaterialProperty<Real>("shear_modulus")),
    _p(isParamValid("non_swelling_pressure") ? &declareADProperty<Real>("non_swelling_pressure")
                                             : nullptr)
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

  // The mechanical stress
  const ADRankTwoTensor d_psi_d_Fm = lambda * std::log(Jm) * Fm_inv_t + G * (Fm - Fm_inv_t);

  // The PK1 stress
  const ADRankTwoTensor P = d_psi_d_Fm * _Fg[_qp].inverse();
  _d_psi_dot_d_F_dot[_qp] = P;

  // The rate of the Helmholtz free energy density
  _psi_dot[_qp] = _d_psi_dot_d_F_dot[_qp].doubleContraction(_F_dot[_qp]);

  // These are some additional derivatives that we may need, eventually
  if (_Fs)
  {
    // For the primal-dual formulation, we need the dpsi/dc as part of the chemical potential
    ADReal p = -P.doubleContraction(_F[_qp] * (*_Fs)[_qp].inverse()) / 3;
    (*_d_psi_dot_d_c_dot)[_qp] = (*_d_Js_d_c)[_qp] * p;

    // If the user asked for it, then we output it
    if (_p)
      (*_p)[_qp] = p;
  }
}
