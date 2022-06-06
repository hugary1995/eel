//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "FicksFirstLaw.h"

registerMooseObject("StingrayApp", FicksFirstLaw);

InputParameters
FicksFirstLaw::validParams()
{
  InputParameters params = ChemicalEnergyDensityBase::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Fick's first law.");
  params.addRequiredParam<MaterialPropertyName>("diffusivity", "The diffusion coefficient tensor");
  return params;
}

FicksFirstLaw::FicksFirstLaw(const InputParameters & parameters)
  : ChemicalEnergyDensityBase(parameters),
    _D(getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("diffusivity", true)))
{
}

ADReal
FicksFirstLaw::computeQpChemicalEnergyDensity() const
{
  return (_D[_qp] * _grad_c[_qp]) * _grad_c[_qp];
}

ADReal
FicksFirstLaw::computeQpDChemicalEnergyDensityDConcentration()
{
  return 0;
}

ADRealVectorValue
FicksFirstLaw::computeQpDChemicalEnergyDensityDConcentrationGradient()
{
  return _D[_qp] * _grad_c[_qp];
}

ADRankTwoTensor
FicksFirstLaw::computeQpDChemicalEnergyDensityDDeformationGradient()
{
  ADRankTwoTensor zero;
  return zero;
}
