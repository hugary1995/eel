// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ChemicalPotentialTest.h"

registerMooseObject("EelApp", ChemicalPotentialTest);

InputParameters
ChemicalPotentialTest::validParams()
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

ChemicalPotentialTest::ChemicalPotentialTest(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _mu(declareADProperty<Real>("chemical_potential")),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_c_dot(_psi_names.size()),
    _c_var(getVar("concentration", 0))
{
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_c_dot[i] =
        &getMaterialPropertyDerivative<Real, true>(_psi_names[i], "dot(" + _c_var->name() + ")");
}

void
ChemicalPotentialTest::computeQpProperties()
{
  _mu[_qp] = 0;
  for (auto d_psi_d_c_dot : _d_psi_d_c_dot)
    _mu[_qp] += (*d_psi_d_c_dot)[_qp];
}
