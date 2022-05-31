//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "Swelling.h"

registerADMooseObject("stingrayApp", Swelling);

InputParameters
Swelling::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes the eigen deformation gradient due to swelling.");

  params.addRequiredParam<MaterialPropertyName>(
      "swelling_eigen_deformation_gradient",
      "Name of the eigen deformation gradient due to swelling");
  params.addRequiredCoupledVar(
      "chemical_species_concentrations",
      "Vector of concentrations of chemical species, each contributing to a portion of the "
      "swelling eigen deformation gradient");
  params.addRequiredCoupledVar(
      "chemical_species_reference_concentrations",
      "Vector of reference concentrations of chemical species, at which no swelling occurs");
  params.addRequiredParam<std::vector<MaterialPropertyName>>(
      "molar_volumes", "Vector of molar volumes for the species.");
  params.addRequiredParam<MaterialPropertyName>("swelling_coefficient", "The swelling coefficient");

  return params;
}

Swelling::Swelling(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _Fg(declareADProperty<RankTwoTensor>(
        prependBaseName("swelling_eigen_deformation_gradient_name", true))),
    _c(adCoupledValues("chemical_species_concentrations")),
    _c_ref(adCoupledValues("chemical_species_reference_concentrations")),
    _Omega_names(getParam<std::vector<MaterialPropertyName>>("molar_volumes")),
    _Omega(_Omega_names.size()),
    _beta(getADMaterialPropertyByName<Real>(prependBaseName("swelling_coefficient", true)))
{
  if (_c.size() != _c_ref.size() || _c.size() != _Omega.size())
    mooseError("Number of chemical species concentrations, reference concentrations, and molar "
               "volumes must be the same");

  // Get molar volums
  for (auto i : make_range(_Omega_names.size()))
    _Omega[i] = &getADMaterialPropertyByName<Real>(_Omega_names[i]);
}

void
Swelling::initQpStatefulProperties()
{
  computeQpProperties();
}

void
Swelling::computeQpProperties()
{
  ADReal Js = 1;

  for (auto i : make_range(_c.size()))
    Js += _beta[_qp] * (*_Omega[i])[_qp] * ((*_c[i])[_qp] - (*_c_ref[i])[_qp]);

  _Fg[_qp] = std::cbrt(Js) * ADRankTwoTensor::Identity();
}
