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
  params.addParam<unsigned int>("patch_polynomial_order", 1, "Order of the patch recovery order");
  return params;
}

CondensedMassDiffusion::CondensedMassDiffusion(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _j(declareADProperty<RealVectorValue>("mass_flux")),
    _M(getADMaterialProperty<Real>("mobility")),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_c_dot(_psi_names.size()),
    _c_var(getVar("concentration", 0)),
    _multi_index(
        MathUtils::multiIndex(_mesh.dimension(), getParam<unsigned int>("patch_polynomial_order"))),
    _q(_multi_index.size())
{
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_c_dot[i] =
        &getMaterialPropertyDerivative<Real, true>(_psi_names[i], "dot(" + _c_var->name() + ")");
}

CondensedMassDiffusion::ADRealEigenVector
CondensedMassDiffusion::basisFunctions(const Point & q_point) const
{
  ADRealEigenVector p(_q);
  for (unsigned int r = 0; r < _multi_index.size(); r++)
  {
    ADReal polynomial = 1.0;
    for (unsigned int c = 0; c < _multi_index[r].size(); c++)
      for (unsigned int p = 0; p < _multi_index[r][c]; p++)
        polynomial *= q_point(c);
    p(r) = polynomial;
  }
  return p;
}

CondensedMassDiffusion::ADRealEigenMatrix
CondensedMassDiffusion::basisFunctionGradients(const Point & q_point) const
{
  ADRealEigenMatrix g(_q, 3);
  for (unsigned int r = 0; r < _multi_index.size(); r++)
    for (unsigned int i = 0; i < _multi_index[r].size(); i++)
    {
      ADReal d = _multi_index[r][i];
      for (unsigned int c = 0; c < _multi_index[r].size(); c++)
        for (unsigned int p = 0; (c == i ? p + 1 : p) < _multi_index[r][c]; p++)
          d *= q_point(c);
      g(r, i) = d;
    }
  return g;
}

void
CondensedMassDiffusion::computeProperties()
{
  // Construct the least squares problem
  ADRealEigenMatrix A = ADRealEigenMatrix::Zero(_q, _q);
  ADRealEigenVector b = ADRealEigenVector::Zero(_q);
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    ADRealEigenVector p = basisFunctions(_q_point[_qp]);
    A += p * p.transpose();
    for (auto d_psi_d_c_dot : _d_psi_d_c_dot)
      b += p * (*d_psi_d_c_dot)[_qp];
  }

  // Solve the least squares fitting
  ADRealEigenVector coef = A.completeOrthogonalDecomposition().solve(b);

  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    // Compute the fitted gradients
    ADRealEigenMatrix G = basisFunctionGradients(_q_point[_qp]);
    ADRealEigenVector grad_mu = G.transpose() * coef;
    _j[_qp] = -_M[_qp] * ADRealVectorValue(grad_mu(0), grad_mu(1), grad_mu(2));
  }
}
