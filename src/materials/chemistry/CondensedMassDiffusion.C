#include "CondensedMassDiffusion.h"

registerMooseObject("EelApp", CondensedMassDiffusion);

InputParameters
CondensedMassDiffusion::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription("This class defines the mass flux.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "The mass flux name");
  params.addRequiredParam<MaterialPropertyName>("mobility", "The mobility of the species");
  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Names of the energy densities");
  params.addRequiredCoupledVar("concentration", "The concentration of the chemical species");
  return params;
}

CondensedMassDiffusion::CondensedMassDiffusion(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _j(declareADProperty<RealVectorValue>("mass_flux")),
    _M(getADMaterialProperty<Real>("mobility")),
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
CondensedMassDiffusion::computeProperties()
{
  if (isBoundaryMaterial())
    return;

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

  ADRealEigenVector sol;
  sol = ke.ldlt().solve(re);

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    // Interpolate gradient of chemical potential
    ADRealVectorValue grad_mu;
    for (unsigned int i = 0; i < _test.size(); i++)
      grad_mu += _grad_test[i][_qp] * sol(i);

    // Mass flux
    _j[_qp] = -_M[_qp] * grad_mu;
  }
}
