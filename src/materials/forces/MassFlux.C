//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "MassFlux.h"

registerADMooseObject("StingrayApp", MassFlux);

InputParameters
MassFlux::validParams()
{
  InputParameters params = ThermodynamicForce::validParams();
  params.addClassDescription("This class computes the mass flux associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "Name of the mass flux");
  params.addRequiredCoupledVar("concentration", "The concentration variable");
  return params;
}

MassFlux::MassFlux(const InputParameters & parameters)
  : ThermodynamicForce(parameters),
    _J(declareADProperty<RealVectorValue>(prependBaseName("mass_flux", true))),
    _c_name(getVar("concentration", 0)->name()),
    _d_psi_d_grad_c(_psi_names.size())
{
  // Get thermodynamic forces
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_grad_c[i] = &getDefaultMaterialPropertyByName<RealVectorValue, true>(
        derivativePropertyName(_psi_names[i], {"grad_" + _c_name}));
}

void
MassFlux::computeQpProperties()
{
  _J[_qp].zero();
  for (const auto & d_psi_d_grad_c : _d_psi_d_grad_c)
    _J[_qp] += (*d_psi_d_grad_c)[_qp];
}
