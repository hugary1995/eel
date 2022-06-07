//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ChemicalEnergyDensity.h"

InputParameters
ChemicalEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription(
      "This class computes the chemical energy density and its corresponding "
      "thermodynamic forces. We assume the chemical energy density depends "
      "on at least the deformation gradient, the concentrations and the gradients of "
      "concentrations.");
  params.addRequiredCoupledVar(
      "concentration",
      "Concentration of the species associated with this chemical energy density.");
  params.addRequiredParam<MaterialPropertyName>("chemical_energy_density",
                                                "Name of the elastic energy density");
  return params;
}

ChemicalEnergyDensity::ChemicalEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    _c(adCoupledValue("concentration")),
    _grad_c(adCoupledGradient("concentration")),
    _c_name(getVar("concentration", 0)->name()),
    _psi_name(getParam<MaterialPropertyName>("chemical_energy_density")),
    _psi(declareADProperty<Real>(prependBaseName(_psi_name))),
    _d_psi_d_c(
        declareADProperty<Real>(derivativePropertyName(prependBaseName(_psi_name), {_c_name}))),
    _d_psi_d_grad_c(declareADProperty<RealVectorValue>(
        derivativePropertyName(prependBaseName(_psi_name), {"grad_" + _c_name}))),
    _d_psi_d_F(declareADProperty<RankTwoTensor>(derivativePropertyName(
        prependBaseName(_psi_name), {prependBaseName("deformation_gradient")})))
{
}

void
ChemicalEnergyDensity::computeQpProperties()
{
  _d_psi_d_c[_qp] = computeQpDChemicalEnergyDensityDConcentration();
  _d_psi_d_grad_c[_qp] = computeQpDChemicalEnergyDensityDConcentrationGradient();
  _d_psi_d_F[_qp] = computeQpDChemicalEnergyDensityDDeformationGradient();
  _psi[_qp] = computeQpChemicalEnergyDensity();
}
