//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "MassFlux.h"

registerADMooseObject("StingrayApp", MassFlux);

InputParameters
MassFlux::validParams()
{
  InputParameters params = ThermodynamicForce<RealVectorValue>::validParams();
  params.addClassDescription("This class computes the mass flux associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "Name of the mass flux");
  params.addRequiredCoupledVar("concentration", "The concentration variable");
  return params;
}

MassFlux::MassFlux(const InputParameters & parameters)
  : ThermodynamicForce<RealVectorValue>(parameters),
    _c_name(getVar("concentration", 0)->name()),
    _grad_c_dot(_heat ? &adCoupledGradientDot("concentration") : nullptr)
{
  // Get equilibrium forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, "grad_" + _c_name);

  // Get viscous forces
  getThermodynamicForces(_d_psi_dis_d_v, _psi_dis_names, "grad_" + _c_name + "_dot");

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RealVectorValue>(prependBaseName("mass_flux", true));
}
