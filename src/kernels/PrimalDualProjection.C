#include "PrimalDualProjection.h"

registerMooseObject("EelApp", PrimalDualProjection);

InputParameters
PrimalDualProjection::validParams()
{
  InputParameters params = DerivativeMaterialInterface<ADKernelValue>::validParams();
  params.addClassDescription("Projecting a primal variable onto a dual variable");
  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Names of the energy densities");
  params.addRequiredParam<VariableName>("primal_variable", "The primal variable name");
  params.addRequiredCoupledVar("dual_variable", "The dual variable");
  return params;
}

PrimalDualProjection::PrimalDualProjection(const InputParameters & parameters)
  : DerivativeMaterialInterface<ADKernelValue>(parameters),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_s(_psi_names.size()),
    _s_name(getParam<VariableName>("primal_variable")),
    _v(adCoupledValue("dual_variable"))
{
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_s[i] = &getMaterialPropertyDerivative<Real, true>(_psi_names[i], _s_name);
}

ADReal
PrimalDualProjection::precomputeQpResidual()
{
  ADReal res = _v[_qp];
  for (auto d_psi_d_s : _d_psi_d_s)
    res -= (*d_psi_d_s)[_qp];

  return res;
}
