//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "MassSource.h"

registerADMooseObject("StingrayApp", MassSource);

InputParameters
MassSource::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes the mass source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_source", "Name of the mass source");
  params.addRequiredCoupledVar("concentration", "The concentration variable");
  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Vector of energy densities");
  return params;
}

MassSource::MassSource(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    _mu(declareADProperty<Real>(prependBaseName("mass_source", true))),
    _c_name(getVar("concentration", 0)->name()),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_c(_psi_names.size())
{
  // Get thermodynamic forces
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_c[i] = &getDefaultMaterialPropertyByName<Real, true>(
        derivativePropertyName(prependBaseName(_psi_names[i]), {_c_name}));
}

void
MassSource::computeQpProperties()
{
  _mu[_qp] = 0;
  for (const auto & d_psi_d_c : _d_psi_d_c)
    _mu[_qp] += (*d_psi_d_c)[_qp];
}
