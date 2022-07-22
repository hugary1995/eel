#include "FicksFirstLaw.h"

registerMooseObject("StingrayApp", FicksFirstLaw);

InputParameters
FicksFirstLaw::validParams()
{
  InputParameters params = ChemicalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Fick's first law.");
  params.addRequiredParam<MaterialPropertyName>("diffusivity", "The diffusion coefficient tensor");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  return params;
}

FicksFirstLaw::FicksFirstLaw(const InputParameters & parameters)
  : ChemicalEnergyDensity(parameters),
    _D(getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("diffusivity", true))),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature"))
{
}

ADReal
FicksFirstLaw::computeQpChemicalEnergyDensity() const
{
  return 0.5 * _R * _T[_qp] * _D[_qp] * _grad_c[_qp] * _grad_c[_qp] / _c[_qp];
}

ADReal
FicksFirstLaw::computeQpDChemicalEnergyDensityDConcentration()
{
  return 0;
}

ADRealVectorValue
FicksFirstLaw::computeQpDChemicalEnergyDensityDConcentrationGradient()
{
  return _R * _T[_qp] * _D[_qp] * _grad_c[_qp];
}

ADRankTwoTensor
FicksFirstLaw::computeQpDChemicalEnergyDensityDDeformationGradient()
{
  ADRankTwoTensor zero;
  return zero;
}
