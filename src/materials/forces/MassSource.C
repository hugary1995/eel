//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "MassSource.h"

registerADMooseObject("StingrayApp", MassSource);

InputParameters
MassSource::validParams()
{
  InputParameters params = ThermodynamicForce::validParams();
  params.addClassDescription("This class computes the mass source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_source", "Name of the mass source");
  params.addRequiredCoupledVar("concentration", "The concentration variable");
  return params;
}

MassSource::MassSource(const InputParameters & parameters)
  : ThermodynamicForce(parameters),
    _mu(declareADProperty<Real>(prependBaseName("mass_source", true))),
    _c_name(getVar("concentration", 0)->name()),
    _d_psi_d_c(_psi_names.size()),
    _d_psi_dis_d_c_dot(_psi_dis_names.size())
{
  // Get thermodynamic forces
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_c[i] = &getDefaultMaterialPropertyByName<Real, true>(
        derivativePropertyName(_psi_names[i], {_c_name}));
  for (auto i : make_range(_psi_dis_names.size()))
    _d_psi_dis_d_c_dot[i] = &getDefaultMaterialPropertyByName<Real, true>(
        derivativePropertyName(_psi_dis_names[i], {_c_name + "_dot"}));
}

void
MassSource::computeQpProperties()
{
  _mu[_qp] = 0;
  for (const auto & d_psi_d_c : _d_psi_d_c)
    _mu[_qp] += (*d_psi_d_c)[_qp];
  for (const auto & d_psi_dis_d_c_dot : _d_psi_dis_d_c_dot)
    _mu[_qp] += (*d_psi_dis_d_c_dot)[_qp];
}
