// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ChemicalPotential.h"

registerMooseObject("EelApp", ChemicalPotential);

InputParameters
ChemicalPotential::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription("This class defines the mass flux.");
  params.addRequiredParam<MaterialPropertyName>("chemical_potential",
                                                "Name of the chemical potential");
  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Names of the energy densities");
  params.addRequiredCoupledVar("concentration", "The concentration of the chemical species");
  return params;
}

ChemicalPotential::ChemicalPotential(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _mu(declareADProperty<Real>("chemical_potential")),
    _grad_mu(declareADPropertyByName<RealVectorValue>(
        "∇" + getParam<MaterialPropertyName>("chemical_potential"))),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_c_dot(_psi_names.size()),
    _c_var(getVar("concentration", 0)),
    _test(_c_var->phi()),
    _grad_test(_c_var->gradPhi())
{
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_c_dot[i] =
        &getMaterialPropertyDerivative<Real, true>(_psi_names[i], "dot(" + _c_var->name() + ")");
}

void
ChemicalPotential::computeProperties()
{
  if (isBoundaryMaterial())
    return;

  auto sol = L2Projection();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    _mu[_qp] = 0;
    _grad_mu[_qp] = 0;
    for (unsigned int i = 0; i < _test.size(); i++)
    {
      _mu[_qp] += _test[i][_qp] * sol(i);
      _grad_mu[_qp] += _grad_test[i][_qp] * sol(i);
    }
  }
}

EelUtils::ADRealEigenVector
ChemicalPotential::L2Projection()
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
      Real t = _JxW[_qp] * _coord[_qp] * _test[i][_qp];
      for (auto d_psi_d_c_dot : _d_psi_d_c_dot)
        re(i) += t * (*d_psi_d_c_dot)[_qp];
      for (unsigned int j = 0; j < _test.size(); j++)
        ke(i, j) += t * _test[j][_qp];
    }

  return ke.ldlt().solve(re);
}
