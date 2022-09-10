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
  params.addParam<bool>(
      "condense_dual_problem",
      false,
      "If we condense out the dual problem, some additional second derivatives need "
      "to be computed here.");
  return params;
}

NeoHookeanSolid::NeoHookeanSolid(const InputParameters & parameters)
  : MechanicalEnergyDensity(parameters),
    _lambda(getADMaterialProperty<Real>("lambda")),
    _G(getADMaterialProperty<Real>("shear_modulus")),
    _condensation(getParam<bool>("condense_dual_problem")),
    _d_2_psi_dot_d_c_dot_d_c(_Fs && _condensation
                                 ? &declarePropertyDerivative<Real, true>(
                                       "dot(" + _energy_name + ")", "dot(" + _c_name + ")", _c_name)
                                 : nullptr),
    _d_2_psi_dot_d_c_dot_d_T(_Fs && _Ft && _condensation
                                 ? &declarePropertyDerivative<Real, true>(
                                       "dot(" + _energy_name + ")", "dot(" + _c_name + ")", _T_name)
                                 : nullptr),
    _d_Jt_d_T(_Fs ? &getMaterialPropertyDerivative<Real, true>("det(" + _Ft_name + ")", _T_name)
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

    // Alternatively, if we don't use the primal-dual formulation, i.e. the dual problem is
    // condensed out, we will need to compute some second order derivatives which we can use to
    // compute the chemical potential, i.e. mu = ∇(dpsi/dc) = d2psi/dc2 ∇c + d2psi/dc/dT ∇T
    if (_condensation)
    {
      ADReal Js = (*_Fs)[_qp].det();
      ADReal beta_s = -(*_d_Js_d_c)[_qp] / Js / 3;
      (*_d_2_psi_dot_d_c_dot_d_c)[_qp] =
          (*_d_Js_d_c)[_qp] * beta_s *
          (p - lambda / std::cbrt(Js) - 2. / 3. * G / std::cbrt(Js) * Fm.doubleContraction(Fm));

      if (_Ft)
      {
        ADReal Jt = (*_Ft)[_qp].det();
        ADReal beta_t = -(*_d_Jt_d_T)[_qp] / Jt / 3;
        (*_d_2_psi_dot_d_c_dot_d_T)[_qp] =
            (*_d_Js_d_c)[_qp] * beta_t *
            (-lambda / std::cbrt(Js) - 2. / 3. * G / std::cbrt(Js) * Fm.doubleContraction(Fm));
      }
    }
  }
}
