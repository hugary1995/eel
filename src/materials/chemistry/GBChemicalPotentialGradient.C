#include "GBChemicalPotentialGradient.h"

registerMooseObject("EelApp", GBChemicalPotentialGradient);

InputParameters
GBChemicalPotentialGradient::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculate chemical potential gradient grad(mui) and cavity flux on the grain boundary");
  params.addRequiredParam<MaterialPropertyName>("interface_chemical_potential",
                                                "The chemical potential on the grain boundary");
  params.addRequiredParam<MaterialPropertyName>(
      "interface_mobility",
      "Mobility of the grain boundary cavity (its ability to travel across the interface)");
  params.addRequiredParam<MaterialPropertyName>("cavity_flux", "Name of the cavity flux");
  params.addRequiredCoupledVar("concentration", "The concentration of the chemical species");
  return params;
}

GBChemicalPotentialGradient::GBChemicalPotentialGradient(const InputParameters & parameters)
  : Material(parameters),
    _c_var(getVar("concentration", 0)),
    _test(_c_var->phiFace()),
    _grad_test(_c_var->gradPhiFace()),
    _Mi(getADMaterialProperty<Real>("interface_mobility")),
    _mui(getADMaterialProperty<Real>("interface_chemical_potential")),
    _grad_mui(declareADPropertyByName<RealVectorValue>(
        "∇" + getParam<MaterialPropertyName>("interface_chemical_potential"))),
    _ji(declareADProperty<RealVectorValue>("cavity_flux"))
{
}

void
GBChemicalPotentialGradient::computeProperties()
{
  // compute chemical potential gradient
  auto sol = L2Projection();

  ADRealVectorValue grad_mu_avg = 0;
  Real volume = 0;
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    volume += _JxW[_qp] * _coord[_qp];
    for (unsigned int i = 0; i < _test.size(); i++)
      grad_mu_avg += _grad_test[i][_qp] * sol(i) * _JxW[_qp] * _coord[_qp];
  }
  grad_mu_avg /= volume;

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    _grad_mui[_qp] = grad_mu_avg - (grad_mu_avg * _normals[_qp]) * _normals[_qp];
    _ji[_qp] = -_Mi[_qp] * _grad_mui[_qp];
  }
}

EelUtils::ADRealEigenVector
GBChemicalPotentialGradient::L2Projection()
{
  using EelUtils::ADRealEigenMatrix;
  using EelUtils::ADRealEigenVector;

  unsigned int n_local_dofs = _c_var->numberOfDofs();
  ADRealEigenVector re = ADRealEigenVector::Zero(n_local_dofs);
  ADRealEigenMatrix ke = ADRealEigenMatrix::Zero(n_local_dofs, n_local_dofs);

  // Construct the local L2 projection
  for (unsigned int i = 0; i < _test.size(); i++)
    for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    {
      Real t = _JxW[_qp] * _coord[_qp];
      re(i) += _test[i][_qp] * _mui[_qp];
      for (unsigned int j = 0; j < _test.size(); j++)
        ke(i, j) += _test[i][_qp] * _test[j][_qp];
    }

  return ke.completeOrthogonalDecomposition().solve(re);
}
