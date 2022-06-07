//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ViscousMassTransport.h"

registerMooseObject("StingrayApp", ViscousMassTransport);

InputParameters
ViscousMassTransport::validParams()
{
  InputParameters params = ChemicalDissipationDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the viscous dissipation in mass transport.");
  params.addRequiredParam<MaterialPropertyName>("viscosity", "The mass transport viscosity");
  return params;
}

ViscousMassTransport::ViscousMassTransport(const InputParameters & parameters)
  : ChemicalDissipationDensity(parameters),
    _eta(getADMaterialPropertyByName<Real>(prependBaseName("viscosity", true)))
{
}

ADReal
ViscousMassTransport::computeQpChemicalDissipationDensity() const
{
  return 0.5 * _eta[_qp] * _c_dot[_qp] * _c_dot[_qp];
}

ADReal
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRate()
{
  return _eta[_qp] * _c_dot[_qp];
}

ADRealVectorValue
ViscousMassTransport::computeQpDChemicalDissipationDensityDConcentrationRateGradient()
{
  return ADRealVectorValue(0, 0, 0);
}
