//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "NeoHookeanElasticEnergyDensity.h"

registerMooseObject("StingrayApp", NeoHookeanElasticEnergyDensity);

InputParameters
NeoHookeanElasticEnergyDensity::validParams()
{
  InputParameters params = ElasticEnergyDensityBase::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Neo-Hookean elastic energy density.");

  params.addRequiredParam<MaterialPropertyName>("lambda", "Lame's first parameter");
  params.addRequiredParam<MaterialPropertyName>("shear_modulus", "The shear modulus");

  return params;
}

NeoHookeanElasticEnergyDensity::NeoHookeanElasticEnergyDensity(const InputParameters & parameters)
  : ElasticEnergyDensityBase(parameters),
    _lambda(getADMaterialPropertyByName<Real>(prependBaseName("lambda", true))),
    _G(getADMaterialPropertyByName<Real>(prependBaseName("shear_modulus", true)))
{
}

ADRankTwoTensor
NeoHookeanElasticEnergyDensity::computeQpDElasticEnergyDensityDMechanicalDeformationGradient()
{
  const ADRankTwoTensor Fm_inv_t = _Fm[_qp].inverse().transpose();
  const ADRankTwoTensor P =
      _lambda[_qp] * std::log(_Fm[_qp].det()) * Fm_inv_t + _G[_qp] * (_Fm[_qp] - Fm_inv_t);
  return P;
}

ADReal
NeoHookeanElasticEnergyDensity::computeQpElasticEnergyDensity() const
{
  const ADReal I1 = _Fm[_qp].doubleContraction(_Fm[_qp]);
  const ADReal I3 = _Fm[_qp].det();
  const ADReal psi =
      _G[_qp] * ((I1 - 3) / 2 - std::log(I3)) + _lambda[_qp] * std::log(I3) * std::log(I3) / 2;
  return psi;
}
