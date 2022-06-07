//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ChemicalDissipationDensity.h"

InputParameters
ChemicalDissipationDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class computes the chemical dissipation density and its corresponding "
      "thermodynamic forces. We assume the chemical energy density depends "
      "on at least the rate of change of the concentrations and their gradients.");
  params.addRequiredCoupledVar(
      "concentration",
      "Concentration of the species associated with this chemical energy density.");
  params.addRequiredParam<MaterialPropertyName>("chemical_dissipation_density",
                                                "Name of the chemical dissipation density");
  return params;
}

ChemicalDissipationDensity::ChemicalDissipationDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    _c_dot(adCoupledDot("concentration")),
    _grad_c_dot(adCoupledGradientDot("concentration")),
    _c_name(getVar("concentration", 0)->name()),
    _psi_dis_name(getParam<MaterialPropertyName>("chemical_dissipation_density")),
    _psi_dis(declareADProperty<Real>(prependBaseName(_psi_dis_name))),
    _d_psi_dis_d_c_dot(declareADProperty<Real>(
        derivativePropertyName(prependBaseName(_psi_dis_name), {_c_name + "_dot"}))),
    _d_psi_dis_d_grad_c_dot(declareADProperty<RealVectorValue>(
        derivativePropertyName(prependBaseName(_psi_dis_name), {"grad_" + _c_name + "_dot"})))
{
}

void
ChemicalDissipationDensity::computeQpProperties()
{
  _d_psi_dis_d_c_dot[_qp] = computeQpDChemicalDissipationDensityDConcentrationRate();
  _d_psi_dis_d_grad_c_dot[_qp] = computeQpDChemicalDissipationDensityDConcentrationRateGradient();
  _psi_dis[_qp] = computeQpChemicalDissipationDensity();
}
